using System.Collections;
using UnityEngine;
using UnityEngine.Events;

public class Explosion : MonoBehaviour {

	public float explosionDuration = 1;
	
	void Start()
	{
		foreach (ExplosionInstance explosionInstance in explosionInstances)
			explosionInstance.OnStart();
	}

	private void OnDestroy()
	{
		foreach (ExplosionInstance explosionInstance in explosionInstances)
			explosionInstance.OnDestroy();
	}

	[System.Serializable]
	public class ExplosionInstance
	{
		
		public Renderer _renderer;
		[HideInInspector]
		public Material _material;

		public float heightOffset = 0.5f;

		public void OnStart()
		{
			_material = new Material(_renderer.sharedMaterial);
			_renderer.sharedMaterial = _material;
			_material.SetFloat("_YOffset", heightOffset);
		}

		public void OnDestroy() => Destroy(_material);

		[Tooltip("This remaps the time curve for the visuals.")]
		public AnimationCurve timeRemapCurve = AnimationCurve.Linear(0,0,1,1);
	}


	public ExplosionInstance[] explosionInstances;
	
	private Coroutine makeExplosionCoroutine;

	public new Light light;
	public AnimationCurve lightIntensityCurve = AnimationCurve.Constant(0,1,0);
	
	[EditorButton]
	public void DoExplosion()
	{
		if (!Application.isPlaying)
		{
			Debug.Log("Nah");
			return;
		}

		foreach (ExplosionInstance explosionInstance in explosionInstances)
			explosionInstance._renderer.enabled = true;
		if(makeExplosionCoroutine != null)
			StopCoroutine(makeExplosionCoroutine);
		makeExplosionCoroutine = StartCoroutine(MakeExplosionHappen());
		StartCoroutine(CallExplosionEvent());
		StartCoroutine(CallAudioEvent());
	}

	IEnumerator MakeExplosionHappen()
	{
		float t = 0;
		while (t < explosionDuration)
		{
			float v = t / explosionDuration;
			light.intensity = lightIntensityCurve.Evaluate(v);
			foreach (ExplosionInstance explosionInstance in explosionInstances)
				explosionInstance._material.SetFloat("_Progression", explosionInstance.timeRemapCurve.Evaluate(v));
			t += Time.deltaTime;
			yield return null;
		}
		light.intensity = lightIntensityCurve.Evaluate(1);
		
		foreach (ExplosionInstance explosionInstance in explosionInstances)
		{
			explosionInstance._material.SetFloat("_Progression", 1);
			explosionInstance._renderer.enabled = false;
		}
		
	}
	
	IEnumerator CallExplosionEvent()
	{
		yield return new WaitForSeconds(ExplosionDelay);
		onExplosion.Invoke();
	}
	[Header("Events")]
	public float ExplosionDelay = 0.6f;
	public UnityEvent onExplosion;
	

	IEnumerator CallAudioEvent()
	{
		yield return new WaitForSeconds(audioDelay);
		afterAudioDelay.Invoke();
	}
	public float audioDelay = 1;
	public UnityEvent afterAudioDelay;
}
