using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIFlickerEffect : MonoBehaviour
{
    private Image _image;

    [Tooltip("Minimum random light intensity")]
    public float minIntensity = 0f;
    [Tooltip("Maximum random light intensity")]
    public float maxIntensity = 1f;
    [Tooltip("How much to smooth out the randomness; lower values = sparks, higher = lantern")]
    [Range(1, 50)]
    public int smoothing = 5;

    private Queue<float> smoothQueue;
    float lastSum = 0;

    public void Awake()
    {
        smoothQueue = new Queue<float>(smoothing);
        _image = GetComponent<Image>();

    }

    public void Update()
    {
        // pop off an item if too big
        while(smoothQueue.Count >= smoothing)
        {
            lastSum -= smoothQueue.Dequeue();
        }

        // Generate random new item, calculate new average
        float newVal = Random.Range(minIntensity, maxIntensity);
        smoothQueue.Enqueue(newVal);
        lastSum += newVal;

        // Calculate new smoothed average
        LeanTween.alpha(_image.rectTransform, lastSum / (float)smoothQueue.Count, 0.0f).tweenType = LeanTweenType.easeInOutSine;
    }

}
