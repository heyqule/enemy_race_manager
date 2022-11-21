---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/21/2021 5:34 PM
---

local String = require('__stdlib__/stdlib/utils/string')
local Type = require('__stdlib__/stdlib/utils/type')
local Queue = require('__stdlib__/stdlib/misc/queue')

local Event = require('__stdlib__/stdlib/event/event')
local ErmConfig = require('__enemyracemanager__/lib/global_config')

local CronProcessor = {}

local process_one_job = function(cron_list)
    if(Queue.is_empty(cron_list)) then
        return
    end
    
    local job = cron_list()

    if cron_switch[job[1]] then
        cron_switch[job[1]](job[2])
    else
        log('Invalid Call: '..job[1])
    end
end

local process_all_jobs = function(cron_list)
    if(Queue.is_empty(cron_list)) then
        return
    end

    local cron_list_copy = Queue.new()
    repeat
        cron_list_copy(cron_list())
    until Queue.is_empty(cron_list)

    repeat
        local job = cron_list_copy()
        if cron_switch[job[1]] then
            cron_switch[job[1]](job[2])
        else
            log('Invalid Call: '..job[1])
        end
    until Queue.is_empty(cron_list_copy)
end

function CronProcessor.init_globals()
    global.one_minute_cron = global.one_minute_cron or Queue()
    global.fifteen_seconds_cron = global.fifteen_seconds_cron or Queue()
    global.ten_seconds_cron = global.ten_seconds_cron or Queue()
    global.two_seconds_cron = global.two_seconds_cron or Queue()
    global.one_second_cron = global.one_second_cron or Queue()

    -- Conditional Crons
    global.quick_cron = global.quick_cron or Queue()  -- Spawn
    global.boss_cron = global.boss_cron or Queue()

    -- Multi force Cron.
    global.auto_deploy_cron = global.auto_deploy_cron or {}
    global.teleport_cron = global.teleport_cron or {}
end

function CronProcessor.rebuild_queue()
    Queue.load(global.one_minute_cron)
    Queue.load(global.fifteen_seconds_cron)
    Queue.load(global.ten_seconds_cron)
    Queue.load(global.two_seconds_cron)
    Queue.load(global.one_second_cron)
    Queue.load(global.quick_cron)
    Queue.load(global.boss_cron)

    if Type.Table(global.auto_deploy_cron) then
        for _, queue in pairs(global.auto_deploy_cron) do
            Queue.load(queue)
        end
    end

    if Type.Table(global.teleport_cron) then
        for _, queue in pairs(global.teleport_cron) do
            Queue.load(queue)
        end
    end
end

function CronProcessor.add_1_min_queue(request, ...)
    local arg = {...}
    global.one_minute_cron({request, arg})
end

function CronProcessor.add_15_sec_queue(request, ...)
    local arg = {...}
    global.fifteen_seconds_cron({request, arg})
end

function CronProcessor.add_10_sec_queue(request, ...)
    local arg = {...}
    global.ten_seconds_cron({request, arg})
end

function CronProcessor.add_2_sec_queue(request, ...)
    local arg = {...}
    global.two_seconds_cron({request, arg})
end

function CronProcessor.add_1_sec_queue(request, ...)
    local arg = {...}
    global.one_second_cron({request, arg})
end

function CronProcessor.add_quick_queue(request, ...)
    local arg = {...}
    global.quick_cron({request, arg})

    local event_handler = Event.get_event_handler(ErmConfig.QUICK_CRON)
    if event_handler.handlers == nil then
        Event.on_nth_tick(ErmConfig.QUICK_CRON, CronProcessor.process_quick_queue)
    end
end

function CronProcessor.add_boss_queue(request, ...)
    local arg = {...}
    global.boss_cron({request, arg})
end

function CronProcessor.add_teleport_queue(request, ...)
    local args = {...}
    local unit = args[1]
    local force = unit.force

    if global.teleport_cron[force.index] == nil then
        global.teleport_cron[force.index] = Queue()
    end
    global.teleport_cron[force.index]({request, args})
end

function CronProcessor.process_1_min_queue()
    process_all_jobs(global.one_minute_cron)
end

function CronProcessor.process_15_sec_queue()
    process_all_jobs(global.fifteen_seconds_cron)
end

function CronProcessor.process_2_sec_queue()
    process_all_jobs(global.two_seconds_cron)
end

function CronProcessor.process_10_sec_queue()
    process_one_job(global.ten_seconds_cron)
end

function CronProcessor.process_1_sec_queue()
    process_one_job(global.one_second_cron)
end

function CronProcessor.process_quick_queue()
    process_one_job(global.quick_cron)

    if(Queue.is_empty(global.quick_cron)) then
        Event.remove(ErmConfig.QUICK_CRON * -1, CronProcessor.process_quick_queue)
    end
end

function CronProcessor.process_boss_queue()
    process_one_job(global.boss_cron)
end

function CronProcessor.empty_boss_queue()
    global.boss_cron = Queue()
end

function CronProcessor.process_teleport_queue()
    for _, queue in pairs(global.teleport_cron) do
        process_one_job(queue)
    end
end

return CronProcessor
