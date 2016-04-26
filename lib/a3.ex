defmodule Assignment3 do

  @moduledoc """
  -------------------------------------------------------------
  Name: Sam Dindyal, Beverly Li
  Course: CPS506, Winter 2016, Assignment 3
  Due: April 5th 2016
  Credit: This is entirely my own work.

  This project is a simulation of a web crawler written in Elixir. To efficiently identify all the start-tags and links on a web page, our crawler uses regular expressions and stores the matches in two seperate hash maps. The first hash map consists of start-tags. This hash map is used to keep track of the type of start-tag found and the count of that tag. The second hash map stores the links, and consists of the string value of the link and its visit status. All links start off with the visit status set to false. As each page is visited, the status of the link is updated in the hash map to true.

  In the best case scenario, all links found on the web page would be non-relative (in which case the crawler will follow it). To maximize the use of cores, the crawler uses concurrent threads. Every link followed by the crawler is assigned a thread. Agents in Elixir are used to allow threads to retrieve and update the hash maps of the start-tags and links. Each time a web page is done scanning, the thread updates the global count of the start-tags by merging the hash map of the current webpage to the global hash map of the start-tags.
  -------------------------------------------------------------
  """

  # Prepare for and start web crawling with provided arguments
  def run(url, pages, maxDepth, currentDepth) do
    HTTPoison.start

    # Create agents for links and tag counts
    {:ok, linkAgent} = Agent.start_link fn -> [] end    # Contains map of link history
    {:ok, tagAgent} = Agent.start_link fn -> [] end     # Contains a map containing the global tag count

    Agent.update(linkAgent, fn links -> %{url => false} end)    # Add the current url to the link history
    Agent.update(tagAgent, fn tagCount -> %{} end)              # Initialize the map for the global tag count

    # Follow the starting url with the links from the link agent
    links = Agent.get(linkAgent, fn links -> links end)
    followLoop(Map.keys(links), pages, maxDepth, linkAgent, tagAgent)

    # Retrieve the global tag count
    tagCount = Agent.get(tagAgent, fn tagCounts -> tagCounts end)

    # Print the global tag count
    IO.puts "--------------------------------"
    IO.puts "GLOBAL COUNT"
    IO.puts "ROOT URL: #{url}\nMaxPages: #{pages}\t MaxDepth: #{maxDepth}\tCurrentDepth: #{currentDepth}"
    IO.puts "--------------------------------"
    WebStats.printTagCount(tagCount)

  end

  # Recursive function for following URLs

  # Base cases:
  def followLoop([], _, _, _, _) do end         # If there are no links left to follow
  def followLoop(_, 0, _, _, _) do end          # If the maximum follow limit has been reached
  def followLoop(_, _, 0, _, _) do end          # If the maximum depth has been reached

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

      # Update the global tag count with the appropriate Agent
      Agent.update(tagAgent, fn tagCounts -> merge(Map.keys(tagCount), tagCounts, tagCount) end)

      # Merge the links found on this page with the global map of links
      Agent.update(linkAgent, fn links -> mergeLinks(Map.keys(currentLinks), Map.put(links, link, true), currentLinks) end)

      # Get the links found on the current page
      keys = Map.keys(currentLinks) || []

      # Recurse with the new links found
      followLoop(keys, maxFollow-1, depthCounter-1, linkAgent, tagAgent)
    end

    # Continue recursing on previous list of links
    followLoop(link_tail, maxFollow, depthCounter, linkAgent, tagAgent)
  end

  # Start web_stats with or without arguments
  def startOn(url, args \\ []) do
      pages = args[:maxPages] || 3      # Use provided maxPages or the default
      depth = args[:maxDepth] || 10     # Use the provided maxDepth or the default
      run(url, pages, depth, 0)         # Start web_stats
  end

  # Merge two maps of tag counts
  # Base case:
  def merge([], map1, _) do map1 end      # If the keys have all been processed

  # Recurse through all keys and perform appropriate operations in merging both maps
  def merge([tag|tagList], map1, map2) do

    # If the first map has the current tag
    if Map.has_key?(map1, tag) do
        # Combine the two tag counts
        merge(tagList, Map.put(map1, tag, map1[tag] + map2[tag]), map2)
    else  # Otherwise
        # Add the tag count from the second map to the first map
        merge(tagList, Map.put(map1, tag, map2[tag]), map2)
    end
  end

  # Merge two maps of links
  # Base case:
  def mergeLinks([], map1, _) do map1 end     # If there are no more keys to traverse

  # Recurse through all links and perform appropriate operations to merge two maps
  def mergeLinks([link|links], map1, map2) do
    # Add the logical or of whether a link has been visited or not to the first map
    mergeLinks(links, Map.put(map1, link, map1[link] || map2[link]), map2)
  end

  def main(args) do
    Assignment3.startOn("http://cps506.sarg.ryerson.ca")
  end

end
