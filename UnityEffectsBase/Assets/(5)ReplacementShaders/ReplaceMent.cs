using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ReplaceMent : MonoBehaviour
{

    public Shader rpShader;
    public Camera m_Camera;
    // Use this for initialization
    void Start()
    {
        //全部替换渲染
        //GetComponent<Camera> ().SetReplacementShader(rpShader,"");
        //RenderType="rpShader中RenderType"的sunshader进行渲染，
        m_Camera.GetComponent<Camera>().SetReplacementShader(rpShader, "RenderType");
    }
}