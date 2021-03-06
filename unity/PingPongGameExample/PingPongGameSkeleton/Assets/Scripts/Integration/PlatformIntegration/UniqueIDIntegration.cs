/**
 * Copyright 2019 MobiledgeX, Inc. All rights and licenses reserved.
 * MobiledgeX, Inc. 156 2nd Street #408, San Francisco, CA 94105
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

using System;
using UnityEngine;
// We need this one for importing our IOS functions
using System.Runtime.InteropServices;
using DistributedMatchEngine;

namespace MobiledgeXPingPongGame
{
  public class UniqueIDClass : UniqueID
  {

#if UNITY_ANDROID

    public string GetUniqueIDType()
    {
      return "";
    }

    public String GetUniqueID()
    {
      AndroidJavaClass unityPlayer = PlatformIntegrationUtil.GetAndroidJavaClass("com.unity3d.player.UnityPlayer");
      if (unityPlayer == null)
      {
        Debug.Log("Can't get UnityPlayer");
        return null;
      }

      AndroidJavaObject activity = PlatformIntegrationUtil.GetStatic<AndroidJavaObject>(unityPlayer, "currentActivity");
      if (activity == null)
      {
        Debug.Log("Can't find an activity!");
        return null;
      }

      AndroidJavaObject context = PlatformIntegrationUtil.Call<AndroidJavaObject>(activity, "getApplicationContext");
      if (context == null)
      {
        Debug.Log("Can't find an app context!");
        return null;
      }

      AndroidJavaObject contentResolver = PlatformIntegrationUtil.Call<AndroidJavaObject>(context, "getContentResolver");
      if (contentResolver == null)
      {
        Debug.Log("Can't get content resolver from context");
        return null;
      }

      AndroidJavaClass secureClass = PlatformIntegrationUtil.GetAndroidJavaClass("android.provider.Settings$Secure");
      if (secureClass == null)
      {
        Debug.Log("Can't get secure class");
        return null;
      }

      AndroidJavaObject androidID = PlatformIntegrationUtil.GetStatic<AndroidJavaObject>(secureClass, "ANDROID_ID");
      if (androidID == null)
      {
        Debug.Log("Cant get Android ID static string");
        return null;
      }

      object[] parameters = new object[2];
      parameters[0] = contentResolver;
      parameters[1] = androidID;

      string uuid = PlatformIntegrationUtil.CallStatic<string>(secureClass, "getString", parameters);
      return uuid;
    }

#elif UNITY_IOS

    [DllImport("__Internal")]
    private static extern string _getUniqueIDType();

    [DllImport("__Internal")]
    private static extern string _getUniqueID();

    public string GetUniqueIDType()
    {
      string uniqueIDType = null;
      if (Application.platform == RuntimePlatform.IPhonePlayer)
      {
        uniqueIDType = _getUniqueIDType();
      }
      return uniqueIDType;
    }

    public string GetUniqueID()
    {
      string uniqueID = null;
      if (Application.platform == RuntimePlatform.IPhonePlayer)
      {
        uniqueID = _getUniqueID();
      }
      return uniqueID;
    }
#else

    public string GetUniqueIDType()
    {
      Debug.Log("GetUniqueIDType is NOT IMPLEMENTED");
      return null;
    }
    public string GetUniqueID()
    {
      Debug.Log("GetUniqueID is NOT IMPLEMENTED");
      return null;
    }
#endif
  }

  // Used for testing in UnityEditor (any target platform)
  public class TestUniqueIDClass : UniqueID
  {
    public string GetUniqueIDType()
    {
      return "";
    }
    public string GetUniqueID()
    {
      return "";
    }
  }
}