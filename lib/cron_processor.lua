---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/21/2021 5:34 PM
---

local String = require('__stdlib__/stdlib/utils/string')
local Queue = require('__stdlib__/stdlib/misc/queue')

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

    repeat
        local job = cron_list()
        if cron_switch[job[1]] then
            cron_switch[job[1]](job[2])
        else
            log('Invalid Call: '..job[1])
        end
    until Queue.is_empty(cron_list)
end

function CronProcessor.init_globals()
    global.one_minute_cron = global.one_minute_cron or Queue()
    global.thirty_seconds_cron = global.thirty_seconds_cron or Queue()
    global.ten_seconds_cron = global.ten_seconds_cron or Queue()
    global.three_seconds_cron = global.three_seconds_cron or Queue()
    global.one_second_cron = global.one_second_cron or Queue()
end

function CronProcessor.rebuild_queue()
    Queue.load(global.one_minute_cron)
    Queue.load(global.thirty_seconds_cron)
    Queue.load(global.ten_seconds_cron)
    Queue.load(global.three_seconds_cron)
    Queue.load(global.one_second_cron)
end

function CronProcessor.add_1_min_queue(request, ...)
    local arg = {...}
    global.one_minute_cron({request, arg})
end

function CronProcessor.add_30_sec_queue(request, ...)
    local arg = {...}
    global.thirty_seconds_cron({request, arg})
end

function CronProcessor.add_10_sec_queue(request, ...)
    local arg = {...}
    global.ten_seconds_cron({request, arg})
end

function CronProcessor.add_3_sec_queue(request, ...)
    local arg = {...}
    global.three_seconds_cron({request, arg})
end

function CronProcessor.add_1_sec_queue(request, ...)
    local arg = {...}
    global.one_second_cron({request, arg})
end

function CronProcessor.process_1_min_queue()
    process_all_jobs(global.one_minute_cron)
end

function CronProcessor.process_30_sec_queue()
    process_all_jobs(global.thirty_seconds_cron)
end

function CronProcessor.process_3_sec_queue()
    process_all_jobs(global.three_seconds_cron)
end

function CronProcessor.process_10_sec_queue()
    process_one_job(global.ten_seconds_cron)
end

function CronProcessor.process_1_sec_queue()
    process_one_job(global.one_second_cron)
end

return CronProcessor
