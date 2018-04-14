//使用方法：创建Empty并添加这个script。添加meshFilter component,添加高度图(允许读写)。运行游戏可以看见创建的平面。   
//<https://docs.unity3d.com/ScriptReference/Mesh.html>
//<https://docs.unity3d.com/ScriptReference/Mesh.RecalculateNormals.html> 
//<http://wiki.unity3d.com/index.php/CreatePlane>
//[?]need to learn about arrylist creation
//[?]need to pollish how to write content creation for loop
//顶点数据规则：满足左手定则 即为顶点顺序顺时针 法线方向向上 <来自shader QQ群 Maxwell以及Insist>



using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//make script running in edit mode
//<http://shaders_and_effects_cookbook Chapter8>
[ExecuteInEditMode]

public class baseTerrain : MonoBehaviour
{
    public float lenghtU = 10f;
    public float lengthV = 10f;
    [Range(1, 1000)] public int subdivisionU = 50;
    [Range(1, 1000)] public int subdivisionV = 50;
    public float Height;

    public Texture2D heightmap;

    //you can't create struct with arrays, but you could create class with arrays.
    class TerrainMeshInfo
    {
        public Vector3[] Vertices;
        public Vector2[] UV;
        public int[] Triangles;

        public TerrainMeshInfo(Vector3[] Vert, Vector2[] uvs, int[] Tris)
        {
            Vertices = Vert;
            UV = uvs;
            Triangles = Tris;
        }
    }

    TerrainMeshInfo MeshSetup()
    {
        float centerU = lenghtU / 2;
        float centerV = lengthV / 2;
        float lengthUnitU = lenghtU / subdivisionU;
        float lenghtUnitV = lengthV / subdivisionV;
        float uvUnitU = 1f / subdivisionU;
        float uvUnitV = 1f / subdivisionV;

        Vector3[] Vertices = new Vector3[(subdivisionU + 1) * (subdivisionV + 1)];
        Vector2[] UV = new Vector2[(subdivisionU + 1) * (subdivisionV + 1)];
        int[] Triangles = new int[6 * subdivisionU * subdivisionV];

        TerrainMeshInfo terrainInfo;
        terrainInfo = new TerrainMeshInfo(Vertices, UV, Triangles);

        for (int i = 0; i <= subdivisionV; i++)
        {
            for (int j = 0; j <= subdivisionU; j++)
            {
                int Number = i * (subdivisionU + 1) + j;
                Vertices[Number] = new Vector3(j * lengthUnitU - centerU, 0, i * lenghtUnitV - centerV);
            }
        }

        for (int i = 0; i <= subdivisionV; i++)
        {
            for (int j = 0; j <= subdivisionU; j++)
            {
                int Number = i * (subdivisionU + 1) + j;
                UV[Number] = new Vector2(j * uvUnitU, i * uvUnitV);
            }
        }

        for (int i = 0; i < subdivisionV; i++)
        {
            //Debug.Log(i);                 //the way to print a log
            for (int j = 0; j < subdivisionU; j++)
            {
                int TopTriangleVertexA = i * (subdivisionU + 1) + j;
                int TopTriangleVertexB = (i + 1) * (subdivisionU + 1) + j;
                int TopTriangleVertexC = TopTriangleVertexB + 1;

                int BoTtriangleVertexA = TopTriangleVertexA;
                int BoTtriangleVertexB = TopTriangleVertexC;
                int BoTtriangleVertexC = TopTriangleVertexA + 1;

                int TopTriangleNum = (i * subdivisionU + j) * 6;
                int BotTriangleNum = TopTriangleNum + 3;

                Triangles[TopTriangleNum] = TopTriangleVertexA;
                Triangles[TopTriangleNum + 1] = TopTriangleVertexB;
                Triangles[TopTriangleNum + 2] = TopTriangleVertexC;

                Triangles[BotTriangleNum] = BoTtriangleVertexA;
                Triangles[BotTriangleNum + 1] = BoTtriangleVertexB;
                Triangles[BotTriangleNum + 2] = BoTtriangleVertexC;
            }
        }

        return terrainInfo;
    }

    void HeightMapping(TerrainMeshInfo terrainInfo)
    {
        int vertNum = terrainInfo.Vertices.Length;
        for (int i = 0; i < vertNum; i++)
        {
            Vector2 uv = new Vector2();
            uv = terrainInfo.UV[i];
            //[?]how to avoid the calculation is 1 bigger than heightmap.width???
            int x = Mathf.FloorToInt(heightmap.width * uv.x);
            int y = Mathf.FloorToInt(heightmap.height * uv.y);
            terrainInfo.Vertices[i].y += heightmap.GetPixel(x, y).grayscale * Height;
        }
    }

    void Start()
    {
        TerrainMeshInfo terrainInfo = MeshSetup();
        HeightMapping(terrainInfo);
        Mesh mesh = new Mesh();
        mesh.vertices = terrainInfo.Vertices;
        mesh.triangles = terrainInfo.Triangles;
        mesh.uv = terrainInfo.UV;
        mesh.RecalculateNormals();
        //gameObject.AddComponent<MeshFilter>().mesh = mesh; //create error
        //[?]the method above create error for not set to instance of object, why?
        gameObject.AddComponent<MeshFilter>();
        var filter = GetComponent<MeshFilter>();
        filter.mesh = mesh;
    }


    //[?]how to trigger update when an event happen?
    void Update()
    {
        //use sharedMesh rather than mesh for edit mode
        Mesh mesh = GetComponent<MeshFilter>().sharedMesh;
        TerrainMeshInfo terrainInfo = MeshSetup();
        HeightMapping(terrainInfo);
        //need to clear mesh before resize it
        mesh.Clear();
        mesh.vertices = terrainInfo.Vertices;
        mesh.triangles = terrainInfo.Triangles;
        mesh.uv = terrainInfo.UV;
        mesh.RecalculateNormals();
    }

}
