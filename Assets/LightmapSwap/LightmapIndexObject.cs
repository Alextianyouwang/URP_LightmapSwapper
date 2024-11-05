
using UnityEngine;

using EditorUtility = UnityEditor.EditorUtility;

[CreateAssetMenu (menuName = "LightmapIndexObject")]
#if UNITY_EDITOR
public class LightmapIndexObject : ScriptableObject {
    [SerializeField] public int[] LightmapIndex;
    [SerializeField] public Vector4[] LightmapScaleOffset;
    public Vector4[] GetLightmapScaleOffset() {
        return LightmapScaleOffset;
    }
    public int[] GetLightmapIndex() {
        return LightmapIndex;
    }
    public void SetLightmapScaleOffset(Vector4[] value) {
        LightmapScaleOffset = value;
        EditorUtility.SetDirty(this);
    }
    public void SetLightmapIndex(int[] value) {
        LightmapIndex = value;
        EditorUtility.SetDirty(this);
    }
}
#endif