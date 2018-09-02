using System.Collections;
using UnityEngine;
using UnityEngine.Events;

public class FireAtRandomInterval : MonoBehaviour
{

	public float minInterval = 1;
	public float maxInterval = 10;

	public UnityEvent onFire;
	
	void Start () => StartCoroutine(FireRandomInterval());

	IEnumerator FireRandomInterval()
	{
		while (true)
		{
			yield return new WaitForSeconds(Random.Range(minInterval, maxInterval));
			onFire.Invoke();
		}
	}
}
