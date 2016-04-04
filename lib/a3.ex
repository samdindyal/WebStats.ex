defmodule Assignment3 do
  def run(url, pages, maxDepth, currentDepth) do
    HTTPoison.start
    IO.puts "--------------------------------"
    IO.puts "URL: #{url}\nMaxPages: #{pages}\t MaxDepth: #{maxDepth}\tCurrentDepth: #{currentDepth}"
    IO.puts "--------------------------------"
    tags = WebStats.getTags(url)
    if tags != nil do
      links = WebStats.parseHTML(tags, %{}, %{})
      pagesFollowed = 0
      for link <- Map.keys(links) do
        if (currentDepth < maxDepth-1 && pagesFollowed < pages-1) do
          run(link, pages, maxDepth, currentDepth+1)
          Map.put(links, link, true)
          pagesFollowed = pagesFollowed + 1
        end
      end
    end
  end

  def startOn(url, args \\ []) do
      pages = args[:maxPages] || 3
      depth = args[:maxDepth] || 3
      run(url, pages, depth, 0)
  end

  def main(args) do

  end
end
