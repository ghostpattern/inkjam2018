using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(RectTransform)), RequireComponent(typeof(RawImage))]
public class AssignRenderTexture : MonoBehaviour
{
	public Camera renderCamera;
	
	
	[SerializeField, HideInInspector]
	private RectTransform _rectTransform;
	
	[SerializeField, HideInInspector]
	private RawImage _rawImage;
	

	private void Reset()
	{
		_rectTransform = transform as RectTransform;
		_rawImage = GetComponent<RawImage>();
	}

	// Use this for initialization
	void Awake ()
	{
		CanvasScaler c = _rectTransform.GetComponentInParent<CanvasScaler>();
		Vector2 size = _rectTransform.rect.size;
		
		RenderTexture rT = new RenderTexture( Mathf.RoundToInt(size.x), Mathf.RoundToInt(size.y), 1, RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
		rT.Create();
		renderCamera.targetTexture = rT;
		_rawImage.texture = rT;
		
	}
}
