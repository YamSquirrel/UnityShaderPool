using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//From: https://www.alanzucconi.com/2015/07/08/screen-shaders-and-postprocessing-effects-in-unity3d/
[ExecuteInEditMode]
public class basePostprocess : MonoBehaviour
{

    [Range(0f, 1f)] public float intensity;
    private Material material;
    public Shader curShader;

    // Creates a private material used to the effect
    void Awake()
    {
        material = new Material(curShader);
    }

    // Postprocess the image
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        material.SetFloat("_bwBlend", intensity);
        Graphics.Blit(source, destination, material);
    }
}



/*
//From: shader effect cook book Chapter8 
[ExecuteInEditMode]
public class basePostprocess : MonoBehaviour {

    public Shader curShader;
    public float grayScaleAmount = 1.0f;
    private Material curMaterial;

    /////////////////////////////Postprocess Script/////////////////////////////
    //Graphics.Blit process image using material [?]will it be used for normal texture?
    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        if (curShader != null)
        {
            //use SetFloat to change the parameter of material
            material.SetFloat("_bwBlend", grayScaleAmount);
            Graphics.Blit(sourceTexture, destTexture, material);
        }
        else
        {
            Graphics.Blit(sourceTexture, destTexture);
        }
    }

    /////////////////////////////Stabilize Script/////////////////////////////
    //Create material to use postprocess shader
    Material material
    {
        get
        {
            if(curMaterial == null)
            {
                curMaterial = new Material(curShader);
                curMaterial.hideFlags = HideFlags.HideAndDontSave;
            }
            return curMaterial;
        }
    }

    //Check if the system support post effects
    void Start ()
    {
		if(!SystemInfo.supportsImageEffects)
        {
            enabled = false;
            return;
        }
        if(!curShader && !curShader.isSupported)
        {
            enabled = false;
        }
	}

    //Make grayScaleAmount range 0-1
    void Update()
    {
        grayScaleAmount = Mathf.Clamp(grayScaleAmount, 0.0f, 1.0f);
    }

    //Clean up material when object deleted
    void OnDisable()
    {
        if(curMaterial)
        {
            DestroyImmediate(curMaterial);
        }
    }

}
*/

