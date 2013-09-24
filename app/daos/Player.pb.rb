#!/usr/bin/env ruby
# Generated by the protocol buffer compiler. DO NOT EDIT!

require 'protocol_buffers'

module Com
  module Mobile
    module Sanguo
      # forward declarations
      class Player < ::ProtocolBuffers::Message; end
      class PlayerHero < ::ProtocolBuffers::Message; end
      class Hero < ::ProtocolBuffers::Message; end
      class PlayerItem < ::ProtocolBuffers::Message; end
      class Item < ::ProtocolBuffers::Message; end

      class Player < ::ProtocolBuffers::Message
        set_fully_qualified_name "com.mobile.sanguo.Player"

        required :int64, :playerId, 1
        required :string, :name, 2
        optional :int32, :areaId, 3
      end

      class PlayerHero < ::ProtocolBuffers::Message
        set_fully_qualified_name "com.mobile.sanguo.PlayerHero"

        required :int64, :playerId, 1
        repeated ::Com::Mobile::Sanguo::Hero, :heroList, 2
      end

      class Hero < ::ProtocolBuffers::Message
        set_fully_qualified_name "com.mobile.sanguo.Hero"

        required :int64, :heroId, 1
        required :int32, :heroTempId, 2
        required :string, :name, 3
      end

      class PlayerItem < ::ProtocolBuffers::Message
        set_fully_qualified_name "com.mobile.sanguo.PlayerItem"

        required :int64, :playerId, 1
        repeated ::Com::Mobile::Sanguo::Item, :itemList, 2
      end

      class Item < ::ProtocolBuffers::Message
        set_fully_qualified_name "com.mobile.sanguo.Item"

        required :int64, :itemId, 1
        required :int32, :itemTempId, 2
      end

    end
  end
end
