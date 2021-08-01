---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/21/2021 5:34 PM
---

local String = require('__stdlib__/stdlib/utils/string')
local Queue = require('__stdlib__/stdlib/misc/queue')

local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ErmForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local ErmRaceSettingsHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local ErmDebugHelper = require('__enemyracemanager__/lib/debug_helper')

local CronProcessor = {}

local process_cron = function(cron_list)
    if(Queue.is_empty(cron_list)) then
        return
    end
    local job = cron_list()
    job[1](job[2])
end

function CronProcessor.init_globals()
    if global.ten_minutes_cron == nil then
        global.ten_minutes_cron = Queue()
    end
    if global.one_minute_cron == nil then
        global.one_minute_cron = Queue()
    end
    if global.ten_seconds_cron == nil then
        global.ten_seconds_cron = Queue()
    end
    if global.one_second_cron == nil then
        global.one_second_cron = Queue()
    end
end

function CronProcessor.add_10_min_queue(request, ...)
    local arg = {...}
    global.ten_minutes_cron({request, arg})
end

function CronProcessor.add_1_min_queue(request, ...)
    local arg = {...}
    global.one_minute_cron({request, arg})
end

function CronProcessor.add_10_sec_queue(request, ...)
    local arg = {...}
    global.ten_seconds_cron({request, arg})
end

function CronProcessor.add_1_sec_queue(request, ...)
    local arg = {...}
    global.one_second_cron({request, arg})
end

function CronProcessor.process_10_min_queue()
    process_cron(global.ten_minutes_cron)
end

function CronProcessor.process_1_min_queue()
    process_cron(global.one_minute_cron)
end

function CronProcessor.process_10_sec_queue()
    process_cron(global.ten_seconds_cron)
end

function CronProcessor.process_1_sec_queue()
    process_cron(global.one_second_cron)
end

return CronProcessor
