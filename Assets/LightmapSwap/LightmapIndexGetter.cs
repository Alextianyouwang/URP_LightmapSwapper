using UnityEngine;
using System.Linq;
[ExecuteInEditMode]
public class LightmapIndexGetter : MonoBehaviour {
    public LightmapIndexObject LightmapIndexObj;
    public GameObject RendererParent;
    public void OnEnable() {
        if (LightmapIndexObj == null) return;
        MeshRenderer[] renerers = new MeshRenderer [RendererParent.transform.childCount];
        for (int i = 0; i < RendererParent.transform.childCount; i++) {
            renerers[i] = RendererParent.transform.GetChild(i).GetComponent<MeshRenderer>();
            
        }
        LightmapIndexObj.SetLightmapIndex(renerers.Select(x => x.lightmapIndex).ToArray());
        LightmapIndexObj.SetLightmapScaleOffset(renerers.Select(x => x.lightmapScaleOffset).ToArray());
    }
}
