using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestRenderTexture2 : MonoBehaviour
{
    public Camera myCamera;
    // Use this for initialization
    void Start()
    {
        myCamera.depthTextureMode = DepthTextureMode.Depth;
    }

    // Update is called once per frame
    void Update()
    {

    }
}
