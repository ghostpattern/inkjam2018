using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.SceneManagement;
using UnityEngine;

/// <summary>
/// An Editor-Time asset for loading Scenes. A runtime version will need to be built.
/// </summary>
[CreateAssetMenu(fileName = "Scene.asset", menuName = "Scene Data", order = 0)]
public class SceneData : ScriptableObject
{
	public List<SceneAsset> sceneList;

	/// <summary>
	/// Function called when a user tries to open a file, we discover whether this was a Loader and therefore whether it should be loaded
	/// </summary>
	[OnOpenAsset(1)]
	public static bool TryToLoadAssets(int instanceID, int line)
	{
		Object @this = EditorUtility.InstanceIDToObject(instanceID);
		SceneData loader = @this as SceneData;
		if (loader == null)
			return false;
		
		//We currently are not going to support runtime loading of Loaders.
		if (Application.isPlaying)
		{
			Debug.LogWarning("Loading Loaders at Runtime is not currently supported.");
			return true;
		}

		for (int i = 0; i < loader.sceneList.Count; i++)
		{
			SceneAsset sceneAsset = loader.sceneList[i];
			if (sceneAsset == null)
			{
				Debug.Log($"Scene is missing from list on {AssetDatabase.GetAssetPath(loader)}");
				continue;
			}
			EditorSceneManager.OpenScene(AssetDatabase.GetAssetPath(sceneAsset), i == 0 ? OpenSceneMode.Single : OpenSceneMode.Additive);
		}

		return true;
	}
}
