# Real time lightmap swapper for Unity
![ezgif-1-159f9d2f53](https://github.com/user-attachments/assets/e90ef96a-30f9-41cf-9d99-5bde46abd85f)

Assets credit： Hyun Jun Song & Minsic 

2 Workspace scenes and 1 Composition scene are used in this project. They are:
- Main
- Locker_bake
- Subway_bake

Everything runs on the Main scene, no scene loading is required. Enter play mode to run the demo.
This prototype is a workaround to bypass lightmap-scene dependency by manually fetching the per-renderer lightmap and per-scene probe data.
Currently, it supports swapping seamlessly 2 sceneries each having 2 light settings.

---
Proceed if you want to set up  setup from scratch: 

Precautions:
1. Make sure all Workspace scenes and Composition scenes are sharing the EXACT Light probe & Reflection probe setup
2. Make sure to use prefabs to hold all static visual elements of the Workspace scene, all child object needs to have a renderer component


Step 1: Prepare data for each Workspace scene
1. Prepare two folders holding baked data, one should share the same name with the current scene, for example, "Subway_bake" & "Subway_bake1"
2. Do the lighting setup as normal, bake the light, and the scene name folder will be populated with lightmaps
3. Right-click the Project panel to create a scriptable object called "ProbeDataObject"
4. Put script "ProbeDataGetter" on any object of the hierarchy, reference this object, and re-enable it
5. Do steps 2-4 again for the other light setup and save to the other folder, remember to "Ctrl+D" the previous lightmaps to prevent overwrite
7. Finally create another object called "LightMapIndexObject"
8. Put script "LightmapIndexGetter" on any object of the hierarchy, reference it, also reference scene prefab, and re-enable it


Step 2: Hook-up runtime logic
1. Go to the Composition scene, add "RuntimeLightMapManager" to any transform
2. Copy Workspace scene lighting settings and paste them into the hierarchy (recommend using prefab)
3. Reference all the fields with data prepared
4. "Renderer Parent" needs to hold a reference to the scene prefab
5. These scene prefabs need to be set inactive
6. "Setting" is for anything that needs to be toggled with the scene, this is prepared in step 2
8. Make sure the Composition scene is free of static objects, then bake light, this is required for Unity to generate probe data


Step 3: Enter play mode, use the number key to enjoy your scene

---

Copyright <2024> <Tianyou Wang (Alex)>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


