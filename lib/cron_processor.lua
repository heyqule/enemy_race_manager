---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/21/2021 5:34 PM
---

local Type = require("__erm_libs__/stdlib/type")
local Queue = require("__erm_libs__/stdlib/queue")

local GlobalConfig = require("__enemyracemanager__/lib/global_config")

local CronProcessor = {}

local process_one_job = function(cron_list)
    if (Queue.is_empty(cron_list)) then
        return
    end

    local job = cron_list()

    if cron_switch[job[1]] then
        cron_switch[job[1]](job[2])
    else
        log("Invalid Call: " .. job[1])
    end
end

local process_all_jobs = function(cron_list)
    if (Queue.is_empty(cron_list)) then
        return
    end

    repeat
        local job = cron_list()
        CronProcessor.add_quick_queue(job[1], unpack(job[2]))
    until Queue.is_empty(cron_list)
end

local process_all_jobs_as_1s_cron = function(cron_list)
    if (Queue.is_empty(cron_list)) then
        return
    end

    repeat
        local job = cron_list()
        CronProcessor.add_1_sec_queue(job[1], unpack(job[2]))
    until Queue.is_empty(cron_list)
end

function CronProcessor.init_globals()
    storage.one_minute_cron = storage.one_minute_cron or Queue()
    storage.fifteen_seconds_cron = storage.fifteen_seconds_cron or Queue()
    storage.ten_seconds_cron = storage.ten_seconds_cron or Queue()
    storage.two_seconds_cron = storage.two_seconds_cron or Queue()
    storage.one_second_cron = storage.one_second_cron or Queue()

    -- Conditional Crons
    storage.quick_cron = storage.quick_cron or Queue()  -- Spawn
    storage.quick_cron_is_running = false

    storage.boss_cron = storage.boss_cron or Queue()

    -- Multi force Cron.
    storage.teleport_cron = storage.teleport_cron or {}
end

function CronProcessor.rebuild_queue()
    Queue.load(storage.one_minute_cron)
    Queue.load(storage.fifteen_seconds_cron)
    Queue.load(storage.ten_seconds_cron)
    Queue.load(storage.two_seconds_cron)
    Queue.load(storage.one_second_cron)
    Queue.load(storage.quick_cron)
    Queue.load(storage.boss_cron)

    if Type.Table(storage.teleport_cron) then
        for _, queue in pairs(storage.teleport_cron) do
            Queue.load(queue)
        end
    end
end

function CronProcessor.add_1_min_queue(request, ...)
    local args = { ... }
    storage.one_minute_cron({ request, args })
end

function CronProcessor.add_15_sec_queue(request, ...)
    local args = { ... }
    storage.fifteen_seconds_cron({ request, args })
end

function CronProcessor.add_10_sec_queue(request, ...)
    local args = { ... }
    storage.ten_seconds_cron({ request, args })
end

function CronProcessor.add_2_sec_queue(request, ...)
    local args = { ... }
    storage.two_seconds_cron({ request, args })
end

function CronProcessor.add_1_sec_queue(request, ...)
    local args = { ... }
    storage.one_second_cron({ request, args })
end

function CronProcessor.add_quick_queue(request, ...)
    local args = { ... }
    storage.quick_cron({ request, args })

    if storage.quick_cron_is_running == false then
        storage.quick_cron_is_running = true
        script.on_nth_tick(GlobalConfig.QUICK_CRON, CronProcessor.process_quick_queue)
    end
end

function CronProcessor.add_boss_queue(request, ...)
    local args = { ... }
    storage.boss_cron({ request, args })
end

function CronProcessor.add_teleport_queue(request, ...)
    local args = { ... }
    local unit = args[1]
    local force = unit.force

    if storage.teleport_cron[force.index] == nil then
        storage.teleport_cron[force.index] = Queue()
    end
    storage.teleport_cron[force.index]({ request, args })
end

function CronProcessor.process_1_min_queue()
    process_all_jobs(storage.one_minute_cron)
end

function CronProcessor.process_15_sec_queue()
    process_all_jobs(storage.fifteen_seconds_cron)
end

function CronProcessor.process_2_sec_queue()
    process_all_jobs(storage.two_seconds_cron)
end

function CronProcessor.process_10_sec_queue()
    process_all_jobs_as_1s_cron(storage.ten_seconds_cron)
end

function CronProcessor.process_1_sec_queue()
    process_one_job(storage.one_second_cron)
end

function CronProcessor.process_quick_queue()
    process_one_job(storage.quick_cron)

     if storage.quick_cron_is_running == true and Queue.is_empty(storage.quick_cron) then
         storage.quick_cron_is_running = false
         script.on_nth_tick(GlobalConfig.QUICK_CRON, nil)
     end
end

function CronProcessor.process_boss_queue()
    process_one_job(storage.boss_cron)
end

function CronProcessor.empty_boss_queue()
    storage.boss_cron = Queue()
end

function CronProcessor.process_teleport_queue()
    for _, queue in pairs(storage.teleport_cron) do
        process_one_job(queue)
    end
end

return CronProcessor
