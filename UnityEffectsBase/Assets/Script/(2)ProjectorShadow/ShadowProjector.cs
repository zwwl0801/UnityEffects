using UnityEngine;
using System.Collections;
using Assets.Script.Utils;
using System.Collections.Generic;

public class ShadowProjector : MonoBehaviour 
{
    private Projector _projector;
    //
    private Camera _lightCamera = null;
    private RenderTexture _shadowTex;
    //
    private Camera _mainCamera;
    private List<Renderer> _shadowCasterList = new List<Renderer>();
    private BoxCollider _boundsCollider;
    public float boundsOffset = 1;//边界偏移，
    public Shader shadowReplaceShader;
    public GameObject testTex;
	void Start () 
    {
        _projector = GetComponent<Projector>();
        _mainCamera = GameObject.FindGameObjectWithTag("MainCamera").GetComponent<Camera>();
        //
        if(_lightCamera == null)
        {
            _lightCamera = gameObject.AddComponent<Camera>();
            _lightCamera.orthographic = true;
            _lightCamera.cullingMask = LayerMask.GetMask("ShadowCaster");
            _lightCamera.clearFlags = CameraClearFlags.SolidColor;
            _lightCamera.backgroundColor = new Color(0,0,0,0);
            _shadowTex = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGB32);
            _shadowTex.filterMode = FilterMode.Bilinear;
            _lightCamera.targetTexture = _shadowTex;

            //意思是只要是带有"RenderType" 标签的就用shadowReplaceShader 进行渲染
            _lightCamera.SetReplacementShader(shadowReplaceShader, "RenderType");

            _projector.material.SetTexture("_ShadowTex", _shadowTex);//投射器的材质的贴图设置为相机看到的东西
            _projector.ignoreLayers = LayerMask.GetMask("ShadowCaster");
        }
         GameObject plane = GameObject.Find("Plane");
         foreach (Transform trans in plane.transform)
         {
             if(trans.gameObject.layer == LayerMask.NameToLayer("ShadowCaster"))
             {
                 _shadowCasterList.Add(trans.gameObject.GetComponent<Renderer>());
             }
         }

        _boundsCollider = new GameObject("Test use to show bounds").AddComponent<BoxCollider>();
	}

    void LateUpdate()
    {
        //求阴影产生物体的包围盒
        Bounds b = new Bounds();
        for (int i = 0; i < _shadowCasterList.Count; i++)
        {
            if(_shadowCasterList[i] != null)
            {
                b.Encapsulate(_shadowCasterList[i].bounds);
            }
        }
        b.extents += Vector3.one * boundsOffset;
#if UNITY_EDITOR
        _boundsCollider.center = b.center;
        _boundsCollider.size = b.size;
#endif
        //根据mainCamera来更新lightCamera和projector的位置，和设置参数
        ShadowUtils.SetLightCamera(b, _lightCamera);
        _projector.aspectRatio = _lightCamera.aspect;
        _projector.orthographicSize = _lightCamera.orthographicSize;
        _projector.nearClipPlane = _lightCamera.nearClipPlane;
        _projector.farClipPlane = _lightCamera.farClipPlane;
	}
    void OnGUI()
    {
        if (GUI.Button(new Rect(10, 70, 50, 30), "Click"))
        {
            MeshRenderer myPlane = testTex.GetComponent<MeshRenderer>();
            myPlane.material.SetTexture("_MainTex", _shadowTex);
            Debug.Log("Clicked the button with text");
        }
    }
}
