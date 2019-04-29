using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NoteBounce : MonoBehaviour
{

    public new AudioSource audio;
    private Material material;


    public float displacementAmount;
    private int m_NumSamples = 1024;
    private float[] m_Samples;
    private float max, sum, rms;
    private Vector3 scale;
    private float volume = 30.0f;
    void Start()
    {
        material = GetComponent<MeshRenderer>().material;
        m_Samples = new float[m_NumSamples];
    }

    // Update is called once per frame
    void Update()
    {
        audio.GetOutputData(m_Samples, 0);
        for (int i = 0; i < m_NumSamples; i++)
        {
            sum = m_Samples[i] * m_Samples[i];
        }
        rms = Mathf.Sqrt(sum / m_NumSamples);
        scale.y = Mathf.Clamp01(rms * volume);
        material.SetFloat("Intensity",scale.y);
    }
}
