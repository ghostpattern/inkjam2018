using System.Collections;
using UnityEngine;
using UnityEngine.Events;

[RequireComponent(typeof(MeshRenderer))]
public class Lightning : MonoBehaviour
{

	[SerializeField, HideInInspector] private MeshRenderer _meshRenderer;
	private Material _material;

	private void Reset()
	{
		_meshRenderer = GetComponent<MeshRenderer>();
	}

	void Start()
	{
		_material = new Material(_meshRenderer.sharedMaterial);
		_meshRenderer.sharedMaterial = _material;
	}

	private void OnDestroy()
	{
		Destroy(_material);
	}

	public float audioDelay = 1;

	public float lightningDuration = 1;
	[Tooltip("This remaps the time curve for the visuals and the light.")]
	public AnimationCurve lightningTimeCurve = AnimationCurve.Linear(0,0,1,1);

	private Coroutine makeLightningCoroutine;

	public new Light light;
	public AnimationCurve lightIntensityCurve = AnimationCurve.Constant(0,1,0);
	
	[EditorButton]
	public void DoLightning()
	{
		if(makeLightningCoroutine != null)
			StopCoroutine(makeLightningCoroutine);
		makeLightningCoroutine = StartCoroutine(MakeLightningHappen());
		StartCoroutine(CallAudioEvent());
	}

	IEnumerator MakeLightningHappen()
	{
		float t = 0;
		while (t < lightningDuration)
		{
			float v = lightningTimeCurve.Evaluate(t / lightningDuration);
			light.intensity = lightIntensityCurve.Evaluate(v);
			_material.SetFloat("_Progression", v);
			t += Time.deltaTime;
			yield return null;
		}
		light.intensity = lightIntensityCurve.Evaluate(1);
		_material.SetFloat("_Progression", 1);
		
	}

	IEnumerator CallAudioEvent()
	{
		yield return new WaitForSeconds(lightningDuration + audioDelay);
		afterAudioDelay.Invoke();
	}
	
	public UnityEvent afterAudioDelay;
	
}
