using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NoteBounce : MonoBehaviour
{

    public new AudioSource audio;
    private Material material;
    void Start()
    {
        material = GetComponent<MeshRenderer>().material;
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
