using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestCamera : MonoBehaviour
{
    //
    public GameObject m_Camera;
    public GameObject m_planeTex;
    // Use this for initialization
    void Start()
    {
        //================================================================
        Camera my_Camera = m_Camera.gameObject.AddComponent<Camera>();
        my_Camera.orthographic = true;
        my_Camera.cullingMask = LayerMask.GetMask("ShadowCaster");
        my_Camera.clearFlags = CameraClearFlags.SolidColor;
        my_Camera.backgroundColor = new Color(0, 0, 0, 0);


        RenderTexture my_shadowTex = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGB32);
        my_shadowTex.filterMode = FilterMode.Bilinear;

        my_Camera.targetTexture = my_shadowTex;

        MeshRenderer myPlane = m_planeTex.GetComponent<MeshRenderer>();
        myPlane.material.SetTexture("_MainTex", my_shadowTex);


        //================================================================
    }

    // Update is called once per frame
    void Update()
    {

    }
}
