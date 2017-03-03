using System.Collections;
using System.Collections.Generic;
using System;
using System.IO;
using System.Diagnostics;
using UnityEngine;

public class ShaderPass : MonoBehaviour
{
	public Material materialShader;
	public string uniformName = "_ShaderPassTexture";
	public RenderTextureFormat textureFormat = RenderTextureFormat.ARGB32;
	public FilterMode filterMode = FilterMode.Point;
	[Range(1,16)] public int levelOfDetails = 1;
	public bool record = false;
	public float frameRate = 30f;

	private FrameBuffer frameBuffer;
	private RenderTexture output;
	private Texture2D texture2D;
	private string path;
	private float firedAt;
	private int index = 0;
	private bool wasRecording = false;
	private string filePath;
	private float timeElapsed;
	private float timeStarted;

	void Start ()
	{
		frameBuffer = new FrameBuffer(1024, 700, 2, textureFormat, filterMode);
		texture2D = new Texture2D(1024, 700);

		path = Application.dataPath;
		List<string> paths = new List<string>(path.Split('/'));
		paths.RemoveAt(paths.Count-1);
		path = String.Join("/", paths.ToArray());
	}

	void Update ()
	{
		if (materialShader) {
			if (!record) {
				Shader.SetGlobalTexture(uniformName, frameBuffer.Apply(materialShader));
				Shader.SetGlobalFloat("_TimeElapsed", Time.time);
				index = 0;
				wasRecording = false;
			} else {

				if (wasRecording == false) {
					wasRecording = true;
					timeStarted = Time.time;
					filePath = System.IO.Path.Combine(path, "Renders") + "/" + DateTime.Now.ToString("yyyyMMddHHmmssffff");
				}

				timeElapsed = Time.time - timeStarted;

				if (firedAt + 1f / frameRate < Time.time) {
					firedAt = Time.time;
					Shader.SetGlobalFloat("_TimeElapsed", Mathf.Clamp01(timeElapsed));
					Shader.SetGlobalTexture(uniformName, frameBuffer.Apply(materialShader));

					if (File.Exists(filePath) == false) {
						Directory.CreateDirectory(filePath);
					}

					RenderTexture.active = frameBuffer.Get();
					texture2D.ReadPixels(new Rect(0, 0, frameBuffer.Get().width, frameBuffer.Get().height), 0, 0);
					texture2D.Apply();
					File.WriteAllBytes(filePath + "/" + index.ToString().PadLeft(3, '0') + ".png", texture2D.EncodeToJPG());
					++index;
				}

				if (timeElapsed >= 1f) {
					record = false;
				}
			}
		}
	}

	public void ChangeLevelOfDetails (int dt)
	{
		levelOfDetails = (int)Mathf.Clamp(levelOfDetails + dt, 1, 16);
		frameBuffer = new FrameBuffer(Screen.width/levelOfDetails, Screen.height/levelOfDetails, 2, textureFormat, filterMode);
	}

	public void Print (Texture2D texture)
	{
		frameBuffer.Print(texture);
	}
}
