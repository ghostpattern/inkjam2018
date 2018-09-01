using UnityEditor;
using UnityEditorInternal;
using UnityEngine;

[CustomEditor(typeof(SceneData))]
public class SceneDataEditor : Editor
{
	private ReorderableList _reorderableList;
	private void OnEnable()
	{
		SerializedProperty sP = serializedObject.FindProperty("sceneList");
		_reorderableList = new ReorderableList(serializedObject, sP)
		{
			drawHeaderCallback = rect => EditorGUI.LabelField(rect, "Scenes", EditorStyles.boldLabel),
			drawElementCallback = (rect, index, active, focused) =>
			{
				rect.height -= 10;
				rect.height /= 2f;
				EditorGUI.ObjectField(rect, sP.GetArrayElementAtIndex(index), GUIContent.none);
				rect.y += EditorGUIUtility.singleLineHeight;
				EditorGUI.TextField(rect, AssetDatabase.GetAssetPath(sP.GetArrayElementAtIndex(index).objectReferenceValue));
			},
			elementHeight = EditorGUIUtility.singleLineHeight * 2 + 10
		};

		
	}

	public override void OnInspectorGUI()
	{
		_reorderableList.DoLayoutList();
		serializedObject.ApplyModifiedProperties();
	}
}
