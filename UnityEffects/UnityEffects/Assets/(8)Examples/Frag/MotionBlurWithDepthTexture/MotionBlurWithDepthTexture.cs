using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlurWithDepthTexture : MonoBehaviour
{
    public Material m_material;
    private Camera m_camera;
    //保存上一帧摄像机的视角 * 投影矩阵
    private Matrix4x4 previousViewProjectionMatrix;
    private Matrix4x4 currentViewProjectionMatrix;
    private Matrix4x4 currentViewProjectionInverseMatrix;
    [Range(0.0f, 1.0f)]
    public float blurSize = 0.5f;
    // Use this for initialization
    void Start()
    {
        m_camera = this.gameObject.GetComponent<Camera>();
        m_camera.depthTextureMode |= DepthTextureMode.Depth;
        previousViewProjectionMatrix = m_camera.projectionMatrix * m_camera.worldToCameraMatrix;
    }
    void OnEnable() 
    {
    }
    // Update is called once per frame
    void Update()
    {

    }
    void OnRenderImage(RenderTexture src,RenderTexture dest) 
    {
        if (m_material != null)
        {
            m_material.SetFloat("_BlurSize", blurSize);
            m_material.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix);

            currentViewProjectionMatrix = m_camera.projectionMatrix * m_camera.worldToCameraMatrix;
            currentViewProjectionInverseMatrix = currentViewProjectionMatrix.inverse;
            m_material.SetMatrix("_CurrentViewProjectionInverseMatrix", currentViewProjectionInverseMatrix);

            previousViewProjectionMatrix = currentViewProjectionMatrix;
            Graphics.Blit(src, dest,m_material);
        }
        else 
        {
            Graphics.Blit(src,dest);
        }
    }
}
