using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class RainTest : MonoBehaviour
{
    public RenderTexture targetTexture;
    public ComputeShader shader;
    public Material mat;
    public float timeSpeed = 1.25f;
    private CommandBuffer buffer;
    private Matrix4x4[] matrix = new Matrix4x4[COUNT];
    private Vector2[] times = new Vector2[COUNT];
    private Material gausBlurMat;
    private int kernal;
    private ComputeBuffer matrixBuffers;
    private ComputeBuffer timeSliceBuffers;

    private const int COUNT = 1023;
    private const float SCALE = 0.02f;

    private void Awake()
    {
        buffer = new CommandBuffer();
        for (int i = 0; i < COUNT; i++)
        {
            times[i] = new Vector2(Random.Range(-1f, 1f), Random.Range(0.8f, 1.2f));
            matrix[i] = Matrix4x4.identity;
            matrix[i].m00 = SCALE;
            matrix[i].m11 = SCALE;
            matrix[i].m22 = SCALE;
            matrix[i].m03 = Random.Range(-1f,1f);
            matrix[i].m13 = Random.Range(-1f,1f);
        }

        matrixBuffers = new ComputeBuffer(COUNT, 64);
        matrixBuffers.SetData(matrix);
        timeSliceBuffers = new ComputeBuffer(COUNT, 8);
        timeSliceBuffers.SetData(times);
        kernal = shader.FindKernel("CSMain");
        //shader.SetBuffer(kernal,ShaderIDs)
    }


    private static Mesh fullScreenMesh;

    public static Mesh FullScreenMesh
    {
        get
        {
            if (fullScreenMesh != null)
                return fullScreenMesh;

            fullScreenMesh = new Mesh();
            fullScreenMesh.vertices = new Vector3[]
            {
                new Vector3(-1,-1,0),
                new Vector3(-1,1,0),
                new Vector3(1,1,0),
                new Vector3(1,-1,0),
            };
            fullScreenMesh.uv = new Vector2[]
            {
                new Vector2(0,1),
                new Vector2(0,0),
                new Vector2(1,0),
                new Vector2(1,1),
            };

            fullScreenMesh.SetIndices(new int[] { 0, 1, 2, 3 }, MeshTopology.Quads, 0);
            return fullScreenMesh;
        }
    }
}
