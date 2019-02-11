using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrightnessSaturationAndContrast : MonoBehaviour
{
    [Range(0, 3)]
    public float mBrightness = 1.0f;
    [Range(0, 3)]
    public float mSaturation = 1.0f;
    [Range(0, 3)]
    public float mContrast = 1.0f;



    private Material mMarterial;
    public Shader mShader;
    // Use this for initialization
    void Start()
    {
        if (mMarterial == null && mShader!= null)
        {
            mMarterial = new Material(mShader);
        }
        else 
        {
        }
    }

    // Update is called once per frame
    void Update()
    {

    }
    void OnRenderImage(RenderTexture src,RenderTexture dest) 
    {
        if (mMarterial != null)
        {
            mMarterial.SetFloat("_Brightness", mBrightness);
            mMarterial.SetFloat("_Saturation", mSaturation);
            mMarterial.SetFloat("_Contrast", mContrast);
            Graphics.Blit(src, dest, mMarterial);
        }
        else 
        {
            Graphics.Blit(src,dest);
        }
    }
}
