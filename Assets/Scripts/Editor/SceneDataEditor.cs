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
			drawElementCallback = (rect, index, active, focused) => EditorGUI.ObjectField(rect, sP.GetArrayElementAtIndex(index), GUIContent.none),
			elementHeight = EditorGUIUtility.singleLineHeight
		};

	}

	public override void OnInspectorGUI()
	{
		_reorderableList.DoLayoutList();
	}
}
