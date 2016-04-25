defmodule WebStats do

  use HTTPoison.Base

  # Get the html from a URL using HTTPoison and hand it over to the handleResponse function
  def getTags(url) do
    HTTPoison.get!(url)
    |> handleResponse
  end

  # Handle the response of attempting to fetch a page's HTML using HTTPoison
  def handleResponse(response) do
    # Get the status_code
    status_code = response.status_code
    case status_code do
      # If the status code indicates success, use regex to scan the html for tags and implicitly return it
      status_code when status_code in 200..299 -> Regex.scan(~r/<[a-zA-Z][^<>]*>/, response.body)

      # Otherwise
      status_code when status_code in 300..399 -> []
      status_code when status_code >= 400      -> []
    end
  end

  # Loop through and print the total tag count
  def printTagCount(tagCount) do

    # Get the keys of each tag count
    links = Enum.sort(Map.keys(tagCount))

    # For each tag, print the tag name and its tag count
    for tag <- links do
        IO.puts "#{tag} #{tagCount[tag]}"
    end
  end

  # Parse the HTML and print out the tag count
  # Base Case:
  def parseHTML([], tagCount, links) do       # If there are no more tags
    # Print out the tag count
    printTagCount(tagCount)

    # Return a list containing the links and tag count found
    [links, tagCount]
  end

  # Recurse through all tags, increment tag count and save new links
  def parseHTML([tags_head | tags_tails], tagCount, links) do

    # Get the entire opening tag and save it in full_tag
    [full_tag | _] = tags_head

    # Get just the tag name
    scan = Regex.scan(~r/<([A-Za-z]+)/, full_tag)
    [[_ | [tag | _]]|_] = scan

    # Convert it to lowercase
    tag = String.downcase(tag)

    # If an anchor tag was found and a non-relative link was found
    if tag == "a" && full_tag =~ ~r/href="((http|https):\/\/[^"]*)"/ do

      # Save link to link variable
      scan = Regex.scan(~r/href="((http|https):\/\/[^"]*)"/, full_tag)
      [[_head|[link|_tail]]|_] = scan

      # Save link to links map and set it as false
      links = Map.put(links, link, false)
    end

    # Recurse for remaining tags and current links and tag count found
    parseHTML(tags_tails, updateCount(tag, tagCount), links)
  end

  # Cascade tag counts
  def updateCount(tag, tagCount) do

    # If the tag already exists
    if Map.has_key?(tagCount, tag) do
        # Increment it
        tagCount = %{ tagCount | tag => tagCount[tag] + 1}
    else  # Otherwise
        # Initialize it to 1
        tagCount = Map.put(tagCount, tag, 1)
    end
  end
end
