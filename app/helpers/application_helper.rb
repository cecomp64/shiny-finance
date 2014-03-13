module ApplicationHelper
  def full_title(page_title)
    base_title = "ShinyFinance"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  # Some helpful formatting for prices
  # Makes negative numbers red and in parentheses
  # Makes positive numbers green
  def dollar_str(amt)
    amt_s = ""

    if amt != nil
      if (amt < 0) 
        amt_s = '<span class="negative_number">($%.2f)</span>' % [amt.abs]
      else
        amt_s = '<span class="positive_number">$%.2f</span>' % [amt]
      end
    end

    return amt_s
  end

  # Some helpful formatting for percentages
  # Makes negative numbers red and in parentheses
  # Makes positive numbers green
  def percent_str(amt)
    amt_s = ""

    if amt != nil
      if (amt < 0) 
        amt_s = "<span class=\"negative_number\">(%.2f%%)</span>" % [amt.abs * 100]
      else
        amt_s = "<span class=\"positive_number\">%.2f%%</span>" % [amt * 100]
      end
    end

    return amt_s
  end



  # table is a hash
  #   table[:class] -- class for table
  #   table[:style] -- string of style info
  #   table[:headings] -- list of th entries
  #     heading[:content] -- html content
  #     heading[:style] -- string of style info
  #     heading[:class] -- string of classes
  #   table[:rows] -- list of rows
  #     row - list of td entries (same as th)
  def table_helper(table)
    # table tag
    table_str = "<table"
    table_str += " class=\"#{table[:class]}\"" if (table[:class])
    table_str += " style=\"#{table[:style]}\"" if (table[:style])
    table_str += ">"

    # headings
    if table[:headings]
      table_str += '<tr>'
      table[:headings].each do |heading|
        table_str += '<th'
        table_str += " class=\"#{heading[:class]}\"" if (heading[:class])
        table_str += " style=\"#{heading[:style]}\"" if (heading[:style])
        table_str += '>'
        table_str += heading[:content] if (heading[:content])
        table_str += '</th>'
      end
      table_str += '</tr>'
    end

    # rows
    if table[:rows]
      table[:rows].each_with_index do |row, i|
        # If we want to make each row a checkbox
        table_str += '<tr'
        table_str += " class=\"alternate_row\"" if (i%2 == 1)
        table_str += '>'
  
        # columns
        #table_str += "<label>"
        row.each do |column|
          class_s = ""
          class_s = column[:style] if (column[:style])
          table_str += '<td'
          table_str += " class=\"#{class_s}\"" if (class_s != "")
          table_str += " style=\"#{column[:style]}\"" if (column[:style])
          table_str += '>'
          table_str += "%s" % [column[:content]] if (column[:content])
          table_str += '</td>'
        end # col


        #table_str += "</label>"
        table_str += '</tr>'
      end # each row
    end # rows

    # end table tag
    table_str += "</table>"

    render inline: table_str
    #return table_str
  end
end
