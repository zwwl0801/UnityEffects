using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestCameras : MonoBehaviour
{
    private Projector _projector;
    public GameObject m_Camera;
    public GameObject m_planeTex;
    // Use this for initialization
    RenderTexture my_shadowTex;
    Camera my_Camera;
    public Shader shadowReplaceShader;
    void Start()
    {
        _projector = GetComponent<Projector>();
        //================================================================
        my_Camera = m_Camera.gameObject.AddComponent<Camera>();
        my_Camera.orthographic = true;
        my_Camera.cullingMask = LayerMask.GetMask("ShadowCaster");
        my_Camera.clearFlags = CameraClearFlags.SolidColor;
        my_Camera.backgroundColor = new Color(0, 0, 0, 0);


        my_shadowTex = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGB32);
        my_shadowTex.filterMode = FilterMode.Bilinear;

        my_Camera.targetTexture = my_shadowTex;

        MeshRenderer myPlane = m_planeTex.GetComponent<MeshRenderer>();
        myPlane.material.SetTexture("_MainTex", my_shadowTex);
        Debug.Log("Clicked the button with text");

        //意思是只要是带有"RenderType" 标签的就用shadowReplaceShader 进行渲染
        //my_Camera.SetReplacementShader(shadowReplaceShader, "RenderType");

        _projector.material.SetTexture("_MainTex", my_shadowTex);//投射器的材质的贴图设置为相机看到的东西
        //my_shadowTex经过投射器以后发生了变化
        _projector.ignoreLayers = LayerMask.GetMask("ShadowCaster");

    }

    // Update is called once per frame
    void Update()
    {

    }
    void OnGUI()
    {
        if (GUI.Button(new Rect(10, 70, 50, 30), "Click"))
        {

        }
    }
}
