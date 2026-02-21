package com.margelo.nitro.alarmkit

import com.facebook.proguard.annotations.DoNotStrip
import com.margelo.nitro.core.Promise

@DoNotStrip
class AlarmKit : HybridAlarmKitSpec() {

  override fun checkAlarmPermission(): Promise<String> {
    return Promise.async { "denied" }
  }
}
