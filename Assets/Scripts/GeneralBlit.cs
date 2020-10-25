using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GeneralBlit : MonoBehaviour
{
    public Material material;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material != null)
        {
            Graphics.Blit(source, destination, material, 0);
        }
    }
}
