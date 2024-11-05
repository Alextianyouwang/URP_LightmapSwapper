using System;
using UnityEngine;
public class RuntimeLightMapManager : MonoBehaviour {
    [SerializeField]public SceneContainer Scene0;
    [SerializeField]public SceneContainer Scene1;
    [System.Serializable]
    public class SceneContainer {
        public Texture2D[] ColorMaps0,ColorMaps1;
        public Texture2D[] DirectionMaps0,DirectionMaps1;
        public LightmapData[] LightMapData0,LightMapData1;
        public ProbeDataObject ProbeData0,ProbeData1;
        public LightmapIndexObject LightmapIndex;
        private ReflectionProbe _probeRoot;
        public Cubemap RefCubemap0, RefCubemap1;
        public Material SkyBox0, SkyBox1;
        public GameObject Setting0, Setting1;
        public GameObject RendererParent;
        private GameObject _geo;
        private void SetUpLightData(Texture2D[] dirArray, Texture2D[] colorArray, ref LightmapData[] data) {
            data = new LightmapData[dirArray.Length];
            for (int i = 0; i < dirArray.Length; i++) {
                data[i] = new LightmapData();
                data[i].lightmapDir = dirArray[i];
                data[i].lightmapColor = colorArray[i];
            }
        }

        public void SetReflectionProbeRoot(ReflectionProbe value) {
            _probeRoot = value;
        }

        public void SetUpAllLightData() {
            SetUpLightData(DirectionMaps0, ColorMaps0, ref LightMapData0);
            SetUpLightData(DirectionMaps1, ColorMaps1, ref LightMapData1);
            _geo = Instantiate(RendererParent);
            _geo.SetActive(false);
            SetupRenderers();
            
        }

        public void SetupRenderers() {
            if (LightmapIndex == null) return;
            if (_geo == null) return;
            int[] indexs = LightmapIndex.GetLightmapIndex();
            Vector4[] scaleOffset = LightmapIndex.GetLightmapScaleOffset();
            for (int i = 0; i < _geo.transform.childCount; i++) {
                _geo.transform.GetChild(i).GetComponent<MeshRenderer>().lightmapIndex = indexs[i];
                _geo.transform.GetChild(i).GetComponent<MeshRenderer>().lightmapScaleOffset = scaleOffset[i];
            }
        }

        public void ToggleGeometry(bool value, int index) {
            _geo.SetActive(value);
            if (value)
                switch (index) {
                    case 0:
                        this.SwitchLight0();
                        if (Setting0 && Setting1) {
                            Setting0.SetActive(true);
                            Setting1.SetActive(false);
                        }
                        break;
                    case 1:
                        this.SwitchLight1();
                        if (Setting0 && Setting1) {
                            Setting0.SetActive(false);
                            Setting1.SetActive(true);
                        }

                        break;
                    default:
                        this.SwitchLight0();
                        if (Setting0 && Setting1) {
                            Setting0.SetActive(true);
                            Setting1.SetActive(false);
                        }
                        break;
                }
            else {
                if (Setting0 && Setting1) {
                    Setting0.SetActive(false);
                    Setting1.SetActive(false);
                }
            }
        }   

        public void SwitchLight0() {
            LightmapSettings.lightmaps = LightMapData0;
            LightmapSettings.lightProbes.bakedProbes = ProbeData0.GetProbeData();
            if (_probeRoot != null && RefCubemap0)
                _probeRoot.customBakedTexture = RefCubemap0;
            if (SkyBox0)
                RenderSettings.skybox = SkyBox0;

        }
        public void SwitchLight1() {
            LightmapSettings.lightmaps = LightMapData1;
            LightmapSettings.lightProbes.bakedProbes = ProbeData1.GetProbeData();
            if (_probeRoot != null && RefCubemap1)
                _probeRoot.customBakedTexture = RefCubemap1;
            if (SkyBox1)
                RenderSettings.skybox = SkyBox1;
        }
    }
    private void Awake() {
        Scene0.SetUpAllLightData();
        Scene1.SetUpAllLightData();
        Scene0.SetReflectionProbeRoot(FindObjectOfType<ReflectionProbe>());
        Scene1.SetReflectionProbeRoot(FindObjectOfType<ReflectionProbe>());
    }

    private void Start() {
        LoadScene0(0);
    }


    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            LoadScene0(0);
        }
        else if(Input.GetKeyDown(KeyCode.Alpha2))
        {
            LoadScene0(1);

        }
        else if(Input.GetKeyDown(KeyCode.Alpha3))
        {
            LoadScene1(0);

        }
        else if(Input.GetKeyDown(KeyCode.Alpha4))
        {
            LoadScene1(1);

        }
    }

    public void LoadScene0(int index) {
        Scene0.ToggleGeometry(true,index);
        Scene1.ToggleGeometry(false,index);
    }
    public void LoadScene1(int index) {
        Scene0.ToggleGeometry(false,index);
        Scene1.ToggleGeometry(true, index);
    }
}
