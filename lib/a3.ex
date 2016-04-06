@moduledoc """
-------------------------------------------------------------
Name: Sam Dindyal, Beverly Li
Course: CPS506, Winter 2016, Assignment 3
Due: April 5th 2016
Credit: This is entirely my own work.

This project is a simulation of a web crawler written in Elixir. Further details about our assignment can be found on GitHub at 	https://github.com/samdindyal/WebStats-Elixir. To efficiently identify all the start-tags and links on a web page, our crawler uses regular expressions and stores the matches in two seperate hash maps. The first hash map consists of start-tags. This hash map is used to keep track of the type of start-tag found and the count of that tag. The second hash map stores the links, and consists of the string value of the link and its visit status. All links start off with the visit status set to false. As each page is visited, the status of the link is updated in the hash map to true.

In the best case scenario, all links found on the web page would be non-relative (in which case the crawler will follow it). To maximize the use of cores, the crawler uses concurrent threads. Every link followed by the crawler is assigned a thread. Agents in Elixir are used to allow threads to retrieve and update the hash maps of the start-tags and links. Each time a web page is done scanning, the thread updates the global count of the start-tags by merging the hash map of the current webpage to the global hash map of the start-tags.
-------------------------------------------------------------
"""

defmodule Assignment3 do

  def run(url, pages, maxDepth, currentDepth) do
    HTTPoison.start

    {:ok, linkAgent} = Agent.start_link fn -> [] end
    {:ok, tagAgent} = Agent.start_link fn -> [] end

    Agent.update(linkAgent, fn links -> %{url => false} end)
    Agent.update(tagAgent, fn tagCount -> %{} end)

    links = Agent.get(linkAgent, fn links -> links end)
    followLoop(Map.keys(links), pages, maxDepth, linkAgent, tagAgent)
    tagCount = Agent.get(tagAgent, fn tagCounts -> tagCounts end)

    IO.puts "--------------------------------"
    IO.puts "GLOBAL COUNT"
    IO.puts "ROOT URL: #{url}\nMaxPages: #{pages}\t MaxDepth: #{maxDepth}\tCurrentDepth: #{currentDepth}"
    IO.puts "--------------------------------"
    WebStats.printTagCount(tagCount)

  end

  def followLoop([], _, _, _, _) do end
  def followLoop(_, 0, _, _, _) do end
  def followLoop(_, _, 0, _, _) do end

  def followLoop([link | link_tail], maxFollow, depthCounter, linkAgent, tagAgent) do

    # If the link has not been visited yet
    links = Agent.get(linkAgent, fn links -> links end)
    if !links[link] do
      IO.puts "--------------------------------"
      IO.puts "URL: #{link}\nDEPTH LIMIT: #{depthCounter}\tFOLLOW LIMIT: #{maxFollow}"
      IO.puts "--------------------------------"
      tags = WebStats.getTags(link)

      # Get new links and tag count then print out tag count
      [currentLinks, tagCount] = WebStats.parseHTML(tags, %{}, %{})

      Agent.update(tagAgent, fn tagCounts -> merge(Map.keys(tagCount), tagCounts, tagCount) end)
      Agent.update(linkAgent, fn links -> mergeLinks(Map.keys(currentLinks), Map.put(links, link, true), currentLinks) end)
      keys = Map.keys(currentLinks) || []
      followLoop(keys, maxFollow-1, depthCounter-1, linkAgent, tagAgent)
    end
    followLoop(link_tail, maxFollow, depthCounter, linkAgent, tagAgent)
  end

  def startOn(url, args \\ []) do
      pages = args[:maxPages] || 10
      depth = args[:maxDepth] || 3
      run(url, pages, depth, 0)
  end

  def merge([], map1, _) do map1 end

  def merge([tag|tagList], map1, map2) do
    if Map.has_key?(map1, tag) do
        merge(tagList, Map.put(map1, tag, map1[tag] + map2[tag]), map2)
    else
        merge(tagList, Map.put(map1, tag, map2[tag]), map2)
    end
  end

  def mergeLinks([], map1, _) do map1 end

  def mergeLinks([link|links], map1, map2) do
    mergeLinks(links, Map.put(map1, link, map1[link] || map2[link]), map2)
  end

  def start_server do
    Task.start_link(fn -> handler end)
  end

  def handler do
    processes = []

    receive do
      {:done, link, process, tagCount} ->
        processes = List.delete(processes, process)

        tagCounts = Agent.get(tagA)

        if List.first(processes) == nil do
          IO.puts "--------------------------------"
          IO.puts "GLOBAL COUNT"
          IO.puts "ROOT URL: #{url}\nMaxPages: #{pages}\t MaxDepth: #{maxDepth}\tCurrentDepth: #{currentDepth}"
          IO.puts "--------------------------------"
          WebStats.printTagCount(tagCounts)
          Process.exit(self(), "Done.")
        end
  end

  def main(args) do
    Assignment3.startOn("http://cps506.sarg.ryerson.ca")
  end

end
