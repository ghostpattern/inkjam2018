using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Ink.Runtime;

public class StoryManager : MonoBehaviour
{
    public TextAsset StoryAsset;
    private Story _inkStory;
    private StoryFeed _storyFeed;

    // Use this for initialization
    void Start()
    {
        _inkStory = new Story(StoryAsset.text);
        _storyFeed = GetComponent<StoryFeed>();
        StartCoroutine(ProcessStory());
    }

    private IEnumerator ProcessStory()
    {
        while(_inkStory.canContinue)
        {
            string inkLine = _inkStory.Continue();

            if(!ParseAction(inkLine))
            {
                float delayTime;
                inkLine = ParseDisplayTime(inkLine, out delayTime);

                delayTime = delayTime < 0.0f ? 2.0f : delayTime;

                _storyFeed.DisplayLine(inkLine);

                while(_storyFeed.DisplayingLine)
                {
                    yield return null;
                }

                float timer = 0.0f;
                while(timer < delayTime)
                {
                    timer += Time.deltaTime;

                    yield return null;

                    if(Input.GetMouseButtonDown(0))
                    {
                        break;
                    }
                }
            }

            if(_inkStory.canContinue == false)
            {
                DisplayCurrentInkChoices();

                while(_inkStory.canContinue == false && _inkStory.currentChoices.Count > 0)
                {
                    yield return null;
                }
            }
        }
    }
    private void DisplayCurrentInkChoices()
    {
        for(int i = 0; i < _inkStory.currentChoices.Count; i++)
        {
            var choiceInstance = _inkStory.currentChoices[i];
            int currChoiceIndex = i;
            _storyFeed.DisplayOptionLine(choiceInstance.text, () =>
            {
                _storyFeed.ClearOptions();
                _inkStory.ChooseChoiceIndex(currChoiceIndex);
            });
        }
    }

    private string ParseDisplayTime(string line, out float displayTime)
    {
        displayTime = -1.0f;

        if(line.EndsWith("]\n"))
        {
            string[] valueAndTime = line.Split('[');
            if(valueAndTime.Length > 1)
            {
                line = valueAndTime[0].Trim(' ', '\t');
                if(float.TryParse(valueAndTime[1].Substring(0, valueAndTime[1].IndexOf("s", StringComparison.Ordinal)), out displayTime) == false)
                {
                    displayTime = -1.0f;
                }
            }
        }

        return line;
    }

    private bool ParseAction(string value)
    {
        value = value.Trim('.', '\n', ' ');

        string[] colonSplit = value.Split(':');

        if(string.Equals(colonSplit[0], "audio", StringComparison.OrdinalIgnoreCase))
        {
            if(colonSplit.Length > 2)
            {
                InkAudioLink linkedAudio = null;
                InkAudioLink[] audioLinks = FindObjectsOfType<InkAudioLink>();
                foreach(InkAudioLink inkAudioLink in audioLinks)
                {
                    if(string.Equals(colonSplit[2], inkAudioLink.Key))
                    {
                        linkedAudio = inkAudioLink;
                    }
                }

                if(linkedAudio != null)
                {
                    if(string.Equals(colonSplit[1], "play", StringComparison.OrdinalIgnoreCase))
                    {
                        float delayTime = 0.0f;
                        if(colonSplit.Length > 3)
                        {
                            float.TryParse(colonSplit[3], out delayTime);
                        }
                        Debug.LogFormat("Playing audio: {0} with delay of {1}", colonSplit[1], delayTime);
                        if(delayTime > 0)
                        {
                            linkedAudio.AudioSource.PlayDelayed(delayTime);
                        }
                        else
                        {
                            linkedAudio.AudioSource.Play();
                        }
                    }
                    else if(string.Equals(colonSplit[1], "fadeup", StringComparison.OrdinalIgnoreCase))
                    {
                        float fadeTime = 0.0f;
                        if(colonSplit.Length > 3)
                        {
                            float.TryParse(colonSplit[3], out fadeTime);
                        }

                        LeanTween.value(linkedAudio.gameObject, v => linkedAudio.AudioSource.volume = v, 0.0f, 1.0f, fadeTime).tweenType = LeanTweenType.easeInOutCubic;
                    }
                    else if(string.Equals(colonSplit[1], "fadedown", StringComparison.OrdinalIgnoreCase))
                    {
                        float fadeTime = 0.0f;
                        if(colonSplit.Length > 3)
                        {
                            float.TryParse(colonSplit[3], out fadeTime);
                        }

                        LeanTween.value(linkedAudio.gameObject, v => linkedAudio.AudioSource.volume = v, linkedAudio.AudioSource.volume, 0.0f, fadeTime).tweenType = LeanTweenType.easeInOutCubic;
                    }
                }
            }

            return true;
        }
        else if(string.Compare(colonSplit[0], "visual", StringComparison.OrdinalIgnoreCase) == 0)
        {
            
        }

        return false;
    }

}
