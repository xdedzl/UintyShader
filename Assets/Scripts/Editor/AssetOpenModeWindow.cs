﻿using System;
using System.Diagnostics;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEngine;

public class AssetOpenModeWindow : EditorWindow
{
    private static CodeOpneMode shaderOpenMode = CodeOpneMode.VSCode;
    private static CodeOpneMode csOpenMode = CodeOpneMode.Default; 

    private AssetOpenModeWindow window;
    private float currentWidth;
    private float currentHeight;

    private void OnEnable()
    {
        Load(); 
    }

    private void OnGUI()
    {
        GUI.backgroundColor = new Color32(0, 170, 255, 50);
        EditorGUILayout.BeginVertical("box");

        GUI.backgroundColor = new Color32(255, 255, 0, 180);
        shaderOpenMode = (CodeOpneMode)EditorGUILayout.EnumPopup("Shader", shaderOpenMode);
        csOpenMode = (CodeOpneMode)EditorGUILayout.EnumPopup("CS", csOpenMode);

        EditorGUILayout.EndVertical();
    }

    private void OnDestroy()
    {
        Save();
    }


    [MenuItem("XDEDZL/Asset/OpenMode")]
    private static void OpenWidown()
    {
        GetWindow(typeof(AssetOpenModeWindow));
    }

    [OnOpenAsset(1)]
    public static bool OpenAsset(int instanceID, int line)
    {
        string fileFullPath = System.IO.Directory.GetParent(Application.dataPath) + "/" + AssetDatabase.GetAssetPath(EditorUtility.InstanceIDToObject(instanceID));

        if (fileFullPath.EndsWith(".shader"))    //文件扩展名类型
        {
            return OpenAssetWithEnd(shaderOpenMode, fileFullPath);
        }
        else if(fileFullPath.EndsWith(".cs"))
        {
            return OpenAssetWithEnd(csOpenMode, fileFullPath);
        }
        return false;
    }

    /// <summary>
    /// 打开文件
    /// </summary>
    private static bool OpenAssetWithEnd(CodeOpneMode mode,string strFileName)
    {
        string fullName = GetFileFullname(mode);
        if (fullName == null)
            return false;
        Process process = new Process();
        ProcessStartInfo startInfo = new ProcessStartInfo();
        startInfo.WindowStyle = ProcessWindowStyle.Hidden;
        startInfo.FileName = GetFileFullname(mode);
        startInfo.Arguments = "\"" + strFileName + "\"";
        process.StartInfo = startInfo;
        process.Start();
        return true;
    }

    /// <summary>
    /// 通过打开方式获取exe完整路径
    /// </summary>
    private static string GetFileFullname(CodeOpneMode mode)
    {
        string editorPath;
        switch (mode)
        {
            case CodeOpneMode.VSCode:
                editorPath = Environment.GetEnvironmentVariable("VSCode_Path");
                return editorPath == null ? null : editorPath + (editorPath.EndsWith("/") ? "" : "/") + "Code.exe";
            case CodeOpneMode.Sublime:
                editorPath = Environment.GetEnvironmentVariable("Sublime_Path");
                return editorPath == null ? null : editorPath + (editorPath.EndsWith("/") ? "" : "/") + "sublime_text.exe";
            default:
                return null;
        }
    }

    /// <summary>
    /// 保存编辑器变量
    /// </summary>
    private void Save()
    {
        EditorPrefs.SetInt("shaderMode", (int)shaderOpenMode);
        EditorPrefs.SetInt("csMode", (int)csOpenMode);
    }

    /// <summary>
    /// 加载编辑器变量
    /// </summary>
    private void Load()
    {
        shaderOpenMode = (CodeOpneMode)EditorPrefs.GetInt("shaderMode", 1);
        csOpenMode = (CodeOpneMode)EditorPrefs.GetInt("csMode", 0);
    }

    enum CodeOpneMode
    {
        Default,
        VSCode,
        Sublime,
    }
}