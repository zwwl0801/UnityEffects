using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlur : MonoBehaviour
{
    public Shader m_shader;
    public Material m_material;

    [Range(0.0f, 0.9f)]
    public float blurAmount = 0.5f;
    private RenderTexture m_accumulationTexture;
    void OnRenderImage(RenderTexture src,RenderTexture dest)
    {
        if (m_material != null)
        {
            if (m_accumulationTexture == null || m_accumulationTexture.width != src.width || m_accumulationTexture.height != src.height)
            {
                DestroyImmediate(m_accumulationTexture);
                m_accumulationTexture = new RenderTexture(src.width,src.height,0);
                m_accumulationTexture.filterMode = FilterMode.Bilinear;
                Graphics.Blit(src, m_accumulationTexture);
            }
            m_accumulationTexture.MarkRestoreExpected();
            m_material.SetFloat("_BlurAmount", 1.0f - blurAmount);

            Graphics.Blit(src, m_accumulationTexture, m_material);
            Graphics.Blit(m_accumulationTexture, dest);
        }
        else 
        {
            Graphics.Blit(src,dest);
        }
    }
    void OnDisable() 
    {
        DestroyImmediate(m_accumulationTexture);
    }
}
