configure do
  # = Configuration =
  set :show_exceptions, development?
  set :raise_errors,    development?
  set :logging,         true
  set :static,          false # your upstream server should deal with those (nginx, Apache)
  set :server,		      'thin'
  set :logging,         true
  set :bind,            '0.0.0.0'
end

configure :production do
end

configure :development do
  set :run,             true
end

configure :test do
  set :run,             false
end

# initialize log
require 'logger'
Dir.mkdir('log') unless File.exist?('log')
class ::Logger; alias_method :write, :<<; end
case ENV["RACK_ENV"]
when "production"
  logger = ::Logger.new("log/production.log",'daily')
  logger.level = ::Logger::WARN
  #memlogger = ::Logger.new("log/memory.log",'daily')
  #memlogger.level = ::Logger::WARN
when "development"
  logger = ::Logger.new(STDOUT)
  logger.level = ::Logger::DEBUG
  #memlogger = ::Logger.new(STDOUT)
  #memlogger.level = ::Logger::DEBUG
when "test"
  logger = ::Logger.new(STDOUT)
  logger.level = ::Logger::DEBUG
  #memlogger = ::Logger.new(STDOUT)
  #memlogger.level = ::Logger::DEBUG
else
  logger = ::Logger.new("/dev/null")
  #memlogger = ::Logger.new("/dev/null")
end

#游戏日志
GameLogger = logger
MemLogger = memlogger

# use Rack::CommonLogger, logger

# initialize json
# require 'active_support'
# ActiveSupport::JSON::Encoding.escape_html_entities_in_json = true

# initialize ActiveRecord
ActiveRecord::Base.establish_connection YAML::load(File.open('config/database.yml'))[ENV["RACK_ENV"]]
# ActiveRecord::Base.logger = logger
ActiveSupport.on_load(:active_record) do
  self.include_root_in_json = false
  self.default_timezone = :local
  self.time_zone_aware_attributes = false
  self.logger = logger
  # self.observers = :cacher, :garbage_collector, :forum_observer
end

# init player data redis
redis_config = YAML.load_file("config/redis.yml")[ENV["RACK_ENV"]]
RedisClient = Redis.new(:host => redis_config['host'], :port => redis_config['port'],:driver => :hiredis)
# init session data redis
redis_config = YAML.load_file("config/session_redis.yml")[ENV["RACK_ENV"]]
SessionRedisClient = Redis.new(:host => redis_config['host'], :port => redis_config['port'],:driver => :hiredis)

# load project config
APP_CONFIG = YAML.load_file(File.expand_path("../config", __FILE__) + '/app_config.yml')[ENV["RACK_ENV"]]

# initialize memcached
# require 'dalli'
# require 'active_support/cache/dalli_store'
Dalli.logger = logger
CACHE = ActiveSupport::Cache::DalliStore.new("127.0.0.1")

# initialize ActiveRecord Cache
# require 'second_level_cache'
SecondLevelCache.configure do |config|
  config.cache_store = CACHE
  config.logger = logger
  config.cache_key_prefix = 'domain'
end

# Set autoload directory 加载一些常用的类
%w{lib utils daos models exception controllers}.each do |dir|
  Dir.glob(File.expand_path("../#{dir}", __FILE__) + '/**/*.rb').each do |file|
    require file
  end
end

#Load game config data from csv file
Dir.glob(File.expand_path("../csvs", __FILE__) + '/**/*.csv').each do |file|
  MetaDao.instance.initMetaDataFromCSV(file)
end

# AOP model method for redis object state exception
# 用来处理redis乐观锁异常的重试逻辑
require 'aquarium'
require 'aquarium/dsl/object_dsl'
include Aquarium::Aspects

Aspect.new :around, :calls_to => :all_methods, :on_types => [Model::Hero, Model::Player, 
  Model::GameArea, Model::Item, Model::Notice],
:method_options =>[:class,:exclude_ancestor_methods] do |join_point, object, *args|
  retrytime = Const::RetryTimes
  result = nil
  while retrytime > 0 
    begin
      #GameLogger.debug("Entering: #{join_point.target_type.name}##{join_point.method_name} for object #{object} arguments #{args * ','}")
      result = join_point.proceed
      if retrytime < Const::RetryTimes 
        #p "Entering retry process #{retrytime}"
      end
      #GameLogger.debug("Leaving: #{join_point.target_type.name}##{join_point.method_name} for object #{object}")
      retrytime = 0
    rescue Exception => ex
      if ex.instance_of?(RedisStaleObjectStateException)
        retrytime = retrytime - 1
      else
        raise ex 
      end
    end
  end
  result
end
