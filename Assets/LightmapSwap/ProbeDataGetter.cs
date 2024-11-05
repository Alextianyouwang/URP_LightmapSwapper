using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ProbeDataGetter : MonoBehaviour {
   
    public ProbeDataObject ProbeObject;
    private void OnEnable() {
        if (ProbeObject == null) return;
        ProbeObject.SetProbeData(LightmapSettings.lightProbes.bakedProbes);
    }
}
