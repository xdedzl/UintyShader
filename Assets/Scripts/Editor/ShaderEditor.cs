using System;
using UnityEditor;
using UnityEngine;

public class ShaderEditor
{
    [UnityEditor.Callbacks.OnOpenAsset(1)]
    public static bool OpenShader(int instanceID, int line)
    {
        string strFilePath = AssetDatabase.GetAssetPath(EditorUtility.InstanceIDToObject(instanceID));
        string strFileName = System.IO.Directory.GetParent(Application.dataPath) + "/" + strFilePath;

        if (strFileName.EndsWith(".shader"))    //文件扩展名类型
        {
            string editorPath = Environment.GetEnvironmentVariable("VSCode_Path");//环境变量名
            if (editorPath != null && editorPath.Length > 0)
            {
                System.Diagnostics.Process process = new System.Diagnostics.Process();
                System.Diagnostics.ProcessStartInfo startInfo = new System.Diagnostics.ProcessStartInfo();
                startInfo.WindowStyle = System.Diagnostics.ProcessWindowStyle.Hidden;
                startInfo.FileName = editorPath + (editorPath.EndsWith("/") ? "" : "/") + "Code.exe";   //你的文件名字
                startInfo.Arguments = "\"" + strFileName + "\"";
                process.StartInfo = startInfo;
                process.Start();
                return true;
            }
            else
            {
                Debug.Log("null environment ： VSCode_Path");
                return false;
            }
        }
        return false;
    }
}