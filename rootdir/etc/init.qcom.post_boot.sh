#!/system/bin/sh
# Copyright (c) 2012-2013, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
target=`getprop ro.board.platform`

case "$target" in
    "msm8994")
         # ensure at most one A57 is online when thermal hotplug is disabled
         echo 0 > /sys/devices/system/cpu/cpu5/online
         echo 0 > /sys/devices/system/cpu/cpu6/online
         echo 0 > /sys/devices/system/cpu/cpu7/online
         # Limit A57 max freq from msm_perf module in case CPU 4 is offline
         echo "4:960000 5:960000 6:960000 7:960000" > /sys/module/msm_performance/parameters/cpu_max_freq
         # disable thermal bcl hotplug to switch governor
         echo 0 > /sys/module/msm_thermal/core_control/enabled
         for mode in /sys/devices/soc.0/qcom,bcl.*/mode
         do
             echo -n disable > $mode
         done
         for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
         do
             bcl_hotplug_mask=`cat $hotplug_mask`
             echo 0 > $hotplug_mask
         done
         for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
         do
             bcl_soc_hotplug_mask=`cat $hotplug_soc_mask`
             echo 0 > $hotplug_soc_mask
         done
         for mode in /sys/devices/soc.0/qcom,bcl.*/mode
         do
             echo -n enable > $mode
         done
         # configure governor settings for little cluster
         echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
         echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_sched_load
         echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_migration_notif
         echo "19000 960000:39000 1248000:29000" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
         echo 95 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
         echo 19000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
         echo 960000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
         echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
         echo "80 960000:95 1248000:99" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
         echo 40000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time
         echo 80000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/max_freq_hysteresis
         echo 384000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
         # online CPU4
         echo 1 > /sys/devices/system/cpu/cpu4/online
         # configure governor settings for big cluster
         echo "interactive" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
         echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_sched_load
         echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_migration_notif
         echo "19000 1400000:39000 1700000:19000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
         echo 95 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load
         echo 19000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
         echo 1248000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
         echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
         echo "90 1248000:95 1800000:70" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
         echo 40000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time
         echo 80000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/max_freq_hysteresis
         echo 384000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
         # insert core_ctl module and use conservative paremeters
         insmod /system/lib/modules/hcube.ko
         echo 1 > /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
         # re-enable thermal and BCL hotplug
         echo 1 > /sys/module/msm_thermal/core_control/enabled
         for mode in /sys/devices/soc.0/qcom,bcl.*/mode
         do
             echo -n disable > $mode
         done
         for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
         do
             echo $bcl_hotplug_mask > $hotplug_mask
         done
         for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
         do
             echo $bcl_soc_hotplug_mask > $hotplug_soc_mask
         done
         for mode in /sys/devices/soc.0/qcom,bcl.*/mode
         do
             echo -n enable > $mode
         done
         # enable LPM
         echo 0 > /sys/module/lpm_levels/parameters/sleep_disabled
         # Restore CPU 4 max freq from msm_performance
         echo "4:4294967295 5:4294967295 6:4294967295 7:4294967295" > /sys/module/msm_performance/parameters/cpu_max_freq
         # input boost configuration
         echo 0:960000 > /sys/module/cpu_boost/parameters/input_boost_freq
         echo 40 > /sys/module/cpu_boost/parameters/input_boost_ms
         # configure core_ctl module parameters
         echo 4 > /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
         echo 0 > /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
         echo 70 > /sys/devices/system/cpu/cpu4/core_ctl/busy_up_thres
         echo 10 > /sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres
         echo 100 > /sys/devices/system/cpu/cpu4/core_ctl/offline_delay_ms
         echo 1 > /sys/devices/system/cpu/cpu4/core_ctl/is_big_cluster
         echo 4 > /sys/devices/system/cpu/cpu4/core_ctl/task_thres
         # configure hcube module parameters
         echo 1 > /sys/devices/system/cpu/cpu4/core_ctl/hc_on
         echo 1 > /sys/devices/system/cpu/cpu4/core_ctl/hc_down_scale_on
         echo 1 > /sys/devices/system/cpu/cpu4/core_ctl/hc_thres_on
         echo 1 > /sys/devices/system/cpu/cpu4/core_ctl/hc_ro_use_gourd
         echo "0 0 768000 1248000" > /sys/devices/system/cpu/cpu4/core_ctl/hc_correl_lvs
         echo 1 > /sys/devices/system/cpu/cpu4/core_ctl/hc_correl_use_pcost
         # Setting b.L scheduler parameters
         echo 1 > /proc/sys/kernel/sched_migration_fixup
         echo 30 > /proc/sys/kernel/sched_small_task
         echo 20 > /proc/sys/kernel/sched_mostly_idle_load
         echo 3 > /proc/sys/kernel/sched_mostly_idle_nr_run
         echo 95 > /proc/sys/kernel/sched_upmigrate
         echo 75 > /proc/sys/kernel/sched_downmigrate
         echo 400000 > /proc/sys/kernel/sched_freq_inc_notify
         echo 400000 > /proc/sys/kernel/sched_freq_dec_notify
         echo 0 > /proc/sys/kernel/sched_boost
         #enable rps static configuration
         echo 8 >  /sys/class/net/rmnet_ipa0/queues/rx-0/rps_cpus
         for devfreq_gov in /sys/class/devfreq/qcom,cpubw*/governor
         do
             echo "bw_hwmon" > $devfreq_gov
         done
         for devfreq_gov in /sys/class/devfreq/qcom,mincpubw*/governor
         do
             echo "cpufreq" > $devfreq_gov
         done

         rm /data/system/perfd/default_values
         setprop ro.min_freq_0 384000
         setprop ro.min_freq_4 384000
         start perfd
    ;;
esac
