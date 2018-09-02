using System.Collections;
using UnityEngine;
using UnityEngine.Events;

public class Lightning : MonoBehaviour
{

	private Renderer _renderer;
	private Material _material;

	void Start()
	{
		_renderer = GetComponent<Renderer>();
		_material = new Material(_renderer.sharedMaterial);
		_renderer.sharedMaterial = _material;
	}

	private void OnDestroy()
	{
		Destroy(_material);
	}

	public float lightningDuration = 1;
	[Tooltip("This remaps the time curve for the visuals and the light.")]
	public AnimationCurve lightningTimeCurve = AnimationCurve.Linear(0,0,1,1);

	private Coroutine makeLightningCoroutine;

	public new Light light;
	public AnimationCurve lightIntensityCurve = AnimationCurve.Constant(0,1,0);
	
	[EditorButton]
	public void DoLightning()
	{
		_renderer.enabled = true;
		if(makeLightningCoroutine != null)
			StopCoroutine(makeLightningCoroutine);
		makeLightningCoroutine = StartCoroutine(MakeLightningHappen());
		StartCoroutine(CallLightningEvent());
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
		_renderer.enabled = false;
		
	}
	
	IEnumerator CallLightningEvent()
	{
		yield return new WaitForSeconds(lightningDelay);
		onLightning.Invoke();
	}
	[Header("Events")]
	public float lightningDelay = 0.6f;
	public UnityEvent onLightning;

	IEnumerator CallAudioEvent()
	{
		yield return new WaitForSeconds(lightningDelay + audioDelay);
		afterAudioDelay.Invoke();
	}
	
	[Tooltip("Final Audio Delay = lightningDelay + audioDelay")]
	public float audioDelay = 1;
	public UnityEvent afterAudioDelay;
	
}
