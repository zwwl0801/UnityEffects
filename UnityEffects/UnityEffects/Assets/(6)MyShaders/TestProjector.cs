using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestProjector : MonoBehaviour
{
    private Projector _projector;
    public GameObject m_Camera;
    public GameObject m_planeTex;
    // Use this for initialization
    RenderTexture my_shadowTex;
    Camera my_Camera;
    public Shader shadowReplaceShader;

    /// <summary>
    /// 1:直接在场景中添加Projector投射器,如果有材质的话， 就会和场景中的进行融合
    /// 2:
    /// </summary>
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



        //意思是只要是带有"RenderType" 标签的就用shadowReplaceShader 进行渲染
        //my_shadowTex经过这一步以后以后发生了变化
        my_Camera.SetReplacementShader(shadowReplaceShader, "RenderType");

        _projector.orthographic = true;
        _projector.material.SetTexture("_ShadowTex", my_shadowTex);//投射器的材质的贴图设置为相机看到的东西
        //
        _projector.ignoreLayers = LayerMask.GetMask("ShadowCaster");
        //UnityEngine.Rendering.CullMode
    }

    // Update is called once per frame
    void Update()
    {

    }
    void OnGUI()
    {
        if (GUI.Button(new Rect(10, 70, 50, 30), "Click"))
        {
            MeshRenderer myPlane = m_planeTex.GetComponent<MeshRenderer>();
            myPlane.material.SetTexture("_MainTex", my_shadowTex);
            Debug.Log("Clicked the button with text");
        }
    }
}
