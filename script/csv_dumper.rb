#!/usr/bin/env ruby

require 'fastercsv'
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
# require 'contact'

class CsvDumper
  def open_output(fn)
    @writer = FasterCSV.open(fn, 'w')
  end

  def dump_contact(c)
    # debugger
    @writer << [
                c.last_name,
                c.first_name,
                c.title,
                c.email,
                c.phone_number,
                c.work_phone,
                c.home_phone,
                c.mobile_phone,
                c.other_phone,
                c.fax,
                address_to_arr(c.address),
                address_to_arr(c.address2),
                c.notes,
                dynamic_attributes_to_arr(c)
               ].flatten
  end

  def address_to_arr(a)
    if a
      [a.address1 || '', a.address2 || '', a.city || '', a.state || '', a.zip || '', a.country || '']
    else
      ['', '', '', '', '', '']
    end
  end

  def dynamic_attributes_to_arr(contact)
    das = []
    DynamicAttribute.find(:all, :order => "name asc").each do |da|
      das << eval("contact.#{da.name}")
    end
    das
  end

  def close_output
    @writer.close
  end

  def dump (contacts)
    contacts.each { |c| dump_contact(c) }
    end
end

output_fn = '/tmp/fmn.csv'
  puts "Dumping all contacts to #{output_fn}..."
cd = CsvDumper.new
cd.open_output(output_fn)
Contact.find(:all).each do |c|
  cd.dump_contact(c)
  putc '.'
end
puts "\nDone."

