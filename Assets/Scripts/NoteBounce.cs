using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class NoteBounce : MonoBehaviour
{
    public GameObject fireworksObj;
    private Material fireworksMat;
    private new AudioSource audio;
    private Material material;

    private int m_NumSamples = 256;
    private float[] m_Samples;
    private float sum, rms;
    void Start()
    {
        audio = GetComponent<AudioSource>();
        material = GetComponent<MeshRenderer>().material;
        fireworksMat = fireworksObj.GetComponent<MeshRenderer>().material;
        m_Samples = new float[m_NumSamples];
    }

    // Update is called once per frame
    void Update()
    {
        audio.GetOutputData(m_Samples, 0);
        sum = m_Samples[m_NumSamples - 1] * m_Samples[m_NumSamples - 1];
        rms = Mathf.Sqrt(sum/* / m_NumSamples*/);
        float intensity = rms;
        Debug.Log(intensity);
        if(intensity > 0.2f)
        {
            fireworksMat.SetFloat("_ContinueTime", 2);
        }
        else
        {
            fireworksMat.SetFloat("_ContinueTime", 0);
        }
        material.SetFloat("_Intensity", intensity);
    }
}


public class AA
{
    private void c()
    {

    }
}

public static class CC
{
    public static void c(this AA a)
    {
        a.c();
    }
}  
