using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEditor;

[CreateAssetMenu (menuName = "ProbDataObject")]
#if UNITY_EDITOR
public class ProbeDataObject : ScriptableObject {
    
    [SerializeField] private SphericalHarmonicsL2[] LightProbeData;

    public SphericalHarmonicsL2[] GetProbeData() {
        return LightProbeData;
    }

    public void SetProbeData(SphericalHarmonicsL2[] lightProbeData) {
        this.LightProbeData = lightProbeData;
        EditorUtility.SetDirty(this);
    }
}
#endif
