using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using UnityEngine;
using Ink.Runtime;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class StoryManager : MonoBehaviour
{
    public TextAsset StoryAsset;
    private Story _inkStory;
    private StoryFeed _storyFeed;
    private float _delayBeforeNextLine;
    private bool _firstAfterChoice = false;

    // Use this for initialization
    void Start()
    {
        _inkStory = new Story(StoryAsset.text);
        _storyFeed = GetComponent<StoryFeed>();
        StartCoroutine(ProcessStory());
    }

    private IEnumerator ProcessStory()
    {
        if(_storyFeed.Title != null)
        {
            LeanTween.value(_storyFeed.Title.gameObject, val =>
            {
                Color color = _storyFeed.Title.color;
                color.a = val;
                _storyFeed.Title.color = color;
            }, 0.0f, 1.0f, _storyFeed.TitleFadeInTime);

            yield return new WaitForSeconds(_storyFeed.TitleFadeInTime + _storyFeed.TitleShowTime);

            while(Input.GetMouseButtonDown(0) == false)
            {
                yield return null;
            }

            LeanTween.value(_storyFeed.Title.gameObject, val =>
            {
                Color color = _storyFeed.Title.color;
                color.a = val;
                _storyFeed.Title.color = color;
            }, 1.0f, 0.0f, _storyFeed.TitleFadeOutTime);

            yield return new WaitForSeconds(_storyFeed.TitleFadeOutTime);
        }
        
        while(_inkStory.canContinue)
        {
            string inkLine = _inkStory.Continue();

            while(_delayBeforeNextLine > 0.0f)
            {
                _delayBeforeNextLine -= Time.deltaTime;
                if(_delayBeforeNextLine < 0.0f)
                    _delayBeforeNextLine = 0.0f;

                yield return null;

                if(Application.isEditor && Input.GetMouseButtonDown(1))
                {
                    _delayBeforeNextLine = 0.0f;
                }
            }

            if(!ParseAction(inkLine))
            {
                float delayTime;
                inkLine = ParseDisplayTime(inkLine, out delayTime);

                delayTime = delayTime < 0.0f ? 2.0f : delayTime;

                _storyFeed.DisplayLine(inkLine, _firstAfterChoice ? StoryFeed.Side.Right : StoryFeed.Side.Left);
                _firstAfterChoice = false;

                while (_storyFeed.DisplayingLine)
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

        while(Input.GetMouseButtonDown(0) == false)
        {
            yield return null;
        }

        SceneManager.LoadScene("Master Scene");
    }
    private void DisplayCurrentInkChoices()
    {
        for(int i = 0; i < _inkStory.currentChoices.Count; i++)
        {
            var choiceInstance = _inkStory.currentChoices[i];
            int currChoiceIndex = i;
            _storyFeed.DisplayOptionLine(choiceInstance.text, () =>
            {
                _firstAfterChoice = true;
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
            string[] commandSplit = colonSplit[1].Trim(' ').Split(' ');
            if(commandSplit.Length > 1)
            {
                List<InkAudioLink> audioLinkList = new List<InkAudioLink>();
                InkAudioLink[] audioLinks = FindObjectsOfType<InkAudioLink>();
                foreach(InkAudioLink inkAudioLink in audioLinks)
                {
                    if(string.Equals(commandSplit[1], inkAudioLink.Key, StringComparison.OrdinalIgnoreCase))
                    {
                        audioLinkList.Add(inkAudioLink);
                    }
                }

                foreach(InkAudioLink inkAudioLink in audioLinkList)
                {
                    if(string.Equals(commandSplit[0], "play", StringComparison.OrdinalIgnoreCase))
                    {
                        float delayTime = 0.0f;
                        if(commandSplit.Length > 2)
                        {
                            float.TryParse(commandSplit[2], out delayTime);
                        }
                        Debug.LogFormat("Playing audio: {0} with delay of {1}", commandSplit[0], delayTime);
                        if(delayTime > 0)
                        {
                            inkAudioLink.AudioSource.PlayDelayed(delayTime);
                        }
                        else
                        {
                            inkAudioLink.AudioSource.Play();
                        }
                    }
                    else if(string.Equals(commandSplit[0], "fadeup", StringComparison.OrdinalIgnoreCase))
                    {
                        float fadeTime = 0.0f;
                        if(commandSplit.Length > 2)
                        {
                            float.TryParse(commandSplit[2], out fadeTime);
                        }

                        LeanTween.value(inkAudioLink.gameObject, v => inkAudioLink.AudioSource.volume = v, 0.0f, 1.0f, fadeTime).tweenType = LeanTweenType.easeInOutCubic;
                    }
                    else if(string.Equals(commandSplit[0], "fadedown", StringComparison.OrdinalIgnoreCase))
                    {
                        float fadeTime = 0.0f;
                        if(commandSplit.Length > 2)
                        {
                            float.TryParse(commandSplit[2], out fadeTime);
                        }

                        LeanTween.value(inkAudioLink.gameObject, v => inkAudioLink.AudioSource.volume = v, inkAudioLink.AudioSource.volume, 0.0f, fadeTime).tweenType = LeanTweenType.easeInOutCubic;
                    }
                }
            }

            return true;
        }
        if(string.Equals(colonSplit[0], "visual", StringComparison.OrdinalIgnoreCase))
        {
            string[] commandSplit = colonSplit[1].Trim(' ').Split(' ');
            if(commandSplit.Length > 0)
            {
                if(string.Equals(commandSplit[0], "fadein", StringComparison.OrdinalIgnoreCase))
                {
                    float fadeTime = 0.0f;
                    if(commandSplit.Length > 1)
                    {
                        float.TryParse(commandSplit[1], out fadeTime);
                    }

                    StorySceneManager.Instance.FadeIn(fadeTime);
                }
                else if(string.Equals(commandSplit[0], "fadeout", StringComparison.OrdinalIgnoreCase))
                {
                    float fadeTime = 0.0f;
                    if(commandSplit.Length > 1)
                    {
                        float.TryParse(commandSplit[1], out fadeTime);
                    }
                    Color fadeColor = Color.black;
                    if(commandSplit.Length > 2)
                    {
                        if(string.Equals(commandSplit[2], "white", StringComparison.OrdinalIgnoreCase))
                        {
                            fadeColor = Color.white;
                        }
                    }

                    StorySceneManager.Instance.FadeOut(fadeTime, fadeColor);
                }
                else if(string.Equals(commandSplit[0], "trigger"))
                {
                    if(string.Equals(commandSplit[1], "lightning", StringComparison.OrdinalIgnoreCase))
                    {
                        Lightning[] lightnings = FindObjectsOfType<Lightning>();

                        if(lightnings.Length > 0)
                        {
                            Lightning lightning = lightnings[UnityEngine.Random.Range(0, lightnings.Length)];

                            float delayTime = 0.0f;
                            if(commandSplit.Length > 2)
                            {
                                float.TryParse(commandSplit[2], out delayTime);
                            }

                            if(delayTime > 0)
                            {
                                lightning.Invoke("DoLightning", delayTime);
                            }
                            else
                            {
                                lightning.DoLightning();
                            }
                        }
                    }
                    else if(string.Equals(commandSplit[1], "explosion", StringComparison.OrdinalIgnoreCase))
                    {
                        float delayTime = 0.0f;
                        if(commandSplit.Length > 2)
                        {
                            float.TryParse(commandSplit[2], out delayTime);
                        }

                        Explosion[] explosions = FindObjectsOfType<Explosion>();
                        foreach(Explosion explosion in explosions)
                        {
                            if(delayTime > 0)
                                explosion.Invoke("DoExplosion", delayTime);
                            else
                                explosion.DoExplosion();
                        }
                    }
                }
                else if(string.Equals(commandSplit[0], "animate", StringComparison.OrdinalIgnoreCase))
                {
                    List<InkVisualLink> visualLinkList = GetVisualLinks(commandSplit[1]);

                    foreach(InkVisualLink inkVisualLink in visualLinkList)
                    {
                        if(commandSplit.Length > 2)
                        {
                            float delayTime = 0.0f;
                            if(commandSplit.Length > 3)
                            {
                                float.TryParse(commandSplit[3], out delayTime);
                            }

                            inkVisualLink.Animate(commandSplit[2], delayTime);
                        }
                    }
                }
                else if(string.Equals(commandSplit[0], "show", StringComparison.OrdinalIgnoreCase))
                {
                    List<InkVisualLink> visualLinkList = GetVisualLinks(commandSplit[1]);

                    foreach(InkVisualLink inkVisualLink in visualLinkList)
                    {
                        float fadeTime = 0.0f;
                        if(commandSplit.Length > 2)
                        {
                            float.TryParse(commandSplit[2], out fadeTime);
                        }
                        
                        inkVisualLink.Show(fadeTime);
                    }
                }
                else if(string.Equals(commandSplit[0], "hide", StringComparison.OrdinalIgnoreCase))
                {
                    List<InkVisualLink> visualLinkList = GetVisualLinks(commandSplit[1]);

                    foreach(InkVisualLink inkVisualLink in visualLinkList)
                    {
                        float fadeTime = 0.0f;
                        if(commandSplit.Length > 2)
                        {
                            float.TryParse(commandSplit[2], out fadeTime);
                        }

                        inkVisualLink.Hide(fadeTime);
                    }
                }
            }

            return true;
        }
        if(string.Equals(colonSplit[0], "scene", StringComparison.OrdinalIgnoreCase))
        {
            string[] commandSplit = colonSplit[1].Trim(' ').Split(' ');
            if(commandSplit.Length > 1)
            {
                if(string.Equals(commandSplit[0], "load", StringComparison.OrdinalIgnoreCase))
                {
                    float delay = 0.0f;
                    if(commandSplit.Length > 2)
                    {
                        float.TryParse(commandSplit[2], out delay);
                    }

                    int sceneNumber;
                    if(int.TryParse(commandSplit[1], out sceneNumber))
                    {
                        StorySceneManager.Instance.LoadScene(sceneNumber, delay);
                    }
                    else
                    {
                        Debug.LogWarningFormat("Couldn't parse '{0}' - couldn't parse int for {1}", value, commandSplit[1]);
                    }
                }
                else
                {
                    Debug.LogWarningFormat("Couldn't parse '{0}' - parse command for {1}", value, commandSplit[0]);
                }
            }
            else
            {
                Debug.LogWarningFormat("Couldn't parse '{0}' - not enough commands", value);
            }

            return true;
        }
        if(string.Equals(colonSplit[0], "delay", StringComparison.OrdinalIgnoreCase))
        {
            float delayTime = 0.0f;
            if(colonSplit.Length > 1)
            {
                float.TryParse(colonSplit[1], out delayTime);
            }
            _delayBeforeNextLine = delayTime;

            return true;
        }

        return false;
    }

    private static List<InkVisualLink> GetVisualLinks(string visualLinkKey)
    {
        List<InkVisualLink> visualLinkList = new List<InkVisualLink>();
        InkVisualLink[] visualLinks = FindObjectsOfType<InkVisualLink>();
        foreach(InkVisualLink inkVisualLink in visualLinks)
        {
            if(string.Equals(visualLinkKey, inkVisualLink.Key, StringComparison.OrdinalIgnoreCase))
            {
                visualLinkList.Add(inkVisualLink);
            }
        }

        return visualLinkList;
    }
}
