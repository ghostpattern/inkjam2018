using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;
using Random = UnityEngine.Random;

public class DriftMove : MonoBehaviour
{

	[SerializeField, HideInInspector] private Transform t;
	private Vector3 originalPosition;
	
	public float radius = 10;

	private void Reset()
	{
		t = transform;
	}

	[FormerlySerializedAs("minSpeedPerUnit")] public float minSpeed = 1;
	[FormerlySerializedAs("maxSpeedPerUnit")] public float maxSpeed = 2;

	// Use this for initialization
	void Start ()
	{
		originalPosition = t.position;
		for (int i = 0; i < positions.Length; i++)
			positions[i] = GetRandomPoint();
		StartCoroutine(DoDrift());
	}
	
	Vector3 GetRandomPoint () => Random.insideUnitSphere * radius + originalPosition;

	readonly Vector3[] positions = new Vector3[4];

	IEnumerator DoDrift()
	{
		float third = 1 / 3f;
		float interpolation = 0;
		while (true)
		{
			float speed = Random.Range(minSpeed, maxSpeed);
			while (interpolation < third)
			{
				t.position = GetCatmullRomPosition(interpolation, positions[0], positions[1], positions[2], positions[3]);
				interpolation += Time.deltaTime * speed;
				yield return null;
			}
			while(interpolation > third)
				interpolation -= third;

			positions[0] = positions[1];
			positions[1] = positions[2];
			positions[2] = positions[3];
			positions[3] = GetRandomPoint();
		}
	}

	private void OnDrawGizmosSelected()
	{
		Gizmos.color = new Color(0.34f, 1f, 0.43f);
		Gizmos.DrawWireSphere(Application.isPlaying ? originalPosition : t.position, radius);
		Gizmos.color = Color.white;
		
		if(!Application.isPlaying) return;

		Vector3 lastP = GetCatmullRomPosition(0, positions[0], positions[1], positions[2], positions[3]);
		for (int i = 1; i <= 100; i++)
		{
			float v = i / 100f;
			Vector3 nextP = GetCatmullRomPosition(v, positions[0], positions[1], positions[2], positions[3]);
			Gizmos.DrawLine(lastP, nextP);
			lastP = nextP;
		}
	}
	
	//Returns a position between 4 Vector3 with Catmull-Rom spline algorithm
	//http://www.iquilezles.org/www/articles/minispline/minispline.htm
	Vector3 GetCatmullRomPosition(float t, Vector3 p0, Vector3 p1, Vector3 p2, Vector3 p3)
	{
		//The coefficients of the cubic polynomial (except the 0.5f * which I added later for performance)
		Vector3 a = 2f * p1;
		Vector3 b = p2 - p0;
		Vector3 c = 2f * p0 - 5f * p1 + 4f * p2 - p3;
		Vector3 d = -p0 + 3f * p1 - 3f * p2 + p3;
	
		//The cubic polynomial: a + b * t + c * t^2 + d * t^3
		Vector3 pos = 0.5f * (a + (b * t) + (c * t * t) + (d * t * t * t));
	
		return pos;
	}
}
