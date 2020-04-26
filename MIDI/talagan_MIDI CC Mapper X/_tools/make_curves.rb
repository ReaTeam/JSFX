#!/usr/bin/env ruby
#
# LICENSE : MIT
#
# MIDI CC Mapper X : Build lib script
# This script is used to build the default library curves.
#
# You can take it as an example script to generate your own files.

require "fileutils"

Dir.chdir(File.dirname(__FILE__))

# This is the default LIB directory (use "user_lib" for your own files)

LIB = "lib"
# LIB = "user_lib"

def make_curve(subdir, func_name, lib=LIB)
    
  dirpath = "../func/#{lib}/#{subdir}"
  
  FileUtils.mkdir_p(dirpath)
  
  File.open("#{dirpath}/#{func_name}.txt","wb") { |f|
    f << "@noindex\n"
    f << "\n"
    f << "# This file was automically generated through MIDIMapperX 'make_curves.rb' generation script.\n\n"
    (0..127).each{ |xi|
      x01 = xi/127.0
      res = yield(x01)
      f   << "%.8f\n" % res
    }
  }
end

# Some transforms
def stepify(x01)
  if x01 <= 0.5
    x01 = 2.0*x01
    yield(x01)/2.0
  else
    x01 = 2.0*(1-x01)
    1 - yield(x01)/2.0
  end
end

def gateify(x01)
  if x01 <= 0.5
    x01 = 2.0 * x01
    yield(x01)
  else
    x01 = 2.0*(1.0-x01)
    yield(x01)
  end
end

def hmirorify(x01)
  yield(1.0-x01)
end

def vmirorify(x01)
  1.0 - yield(x01)
end

# Basic functions
def circ(x01)
  1.0 - Math.sqrt(1.0-x01*x01)
end

def xn(x01,n)
  x01 ** n
end

# Inverse of xn
def ixn(x01,n)
  x01 ** (1.0/n)
end

def expd(x01,d)
  (Math.exp(d * x01) - 1)/(Math.exp(d)-1)
end

# Inverse of expd
def iexpd(x01,d)
  Math.log( x01 * (Math.exp(d) - 1) + 1)/d
end

def lin_stage(x01,q)
  if x01 <= q
    x01/q
  else
    1
  end
end

def lin_step(x01,q)
  if x01 <= q
    0
  else
    1
  end
end

def lin_saw_l(x01,q,scaled)
  if x01 <= q
    ((scaled)?(x01/q):(x01))
  else
    0
  end
end

def lin_saw_r(x01,q,scaled)
  if x01 >= q
    ((scaled)?(x01/q):(x01))
  else
    0
  end
end

def pascalTriangle(a, b)
  r = 1
  0.upto(b-1) { |i|
    r *= 1.0*(a - i) / (i + 1)
  }
  r
end

def generalSmoothStep(order, x01) 
  r = 0
  0.upto(order) { |n|
    r += pascalTriangle( - order - 1, n) *
    pascalTriangle(2 * order + 1, order - n) *
    (x01 ** (order + n + 1))
  }
  r
end

def make_family(family, func, ifunc = nil)
  make_curve(family,"classic")          { |x01| func.call(x01) }
  make_curve(family,"classic_r")        { |x01| vmirorify(x01)  { |x01| func.call(x01) } }
  make_curve(family,"classic_m")        { |x01| hmirorify(x01)  { |x01| func.call(x01) } }
  make_curve(family,"classic_rm")       { |x01| vmirorify(x01)  { |x01| hmirorify(x01) { |x01| func.call(x01) } } }
  make_curve(family,"classic_m_gate")   { |x01| gateify(x01)    { |x01| hmirorify(x01) { |x01| func.call(x01) } } }
  make_curve(family,"classic_rm_gate")  { |x01| gateify(x01)    { |x01| vmirorify(x01) { |x01| hmirorify(x01) { |x01| func.call(x01) } } } }
 
  if ifunc
    make_curve(family,"inverse")          { |x01| ifunc.call(x01) }
    make_curve(family,"inverse_r")        { |x01| vmirorify(x01)  { |x01| ifunc.call(x01) } }
    make_curve(family,"inverse_m")        { |x01| hmirorify(x01)  { |x01| ifunc.call(x01) } }
    make_curve(family,"inverse_rm")       { |x01| vmirorify(x01)  { |x01| hmirorify(x01) { |x01| ifunc.call(x01) } } }
  end
  
  make_curve(family,"step")             { |x01| stepify(x01)    { |x01| func.call(x01) } }
  make_curve(family,"step_m")           { |x01| hmirorify(x01)  { |x01| stepify(x01)   { |x01| func.call(x01) } } }
  make_curve(family,"step_rm")          { |x01| stepify(x01)    { |x01| vmirorify(x01) { |x01| hmirorify(x01) { |x01| func.call(x01) } } } }
  make_curve(family,"step_r")           { |x01| hmirorify(x01)  { |x01| stepify(x01)   { |x01| vmirorify(x01) { |x01| hmirorify(x01) { |x01| func.call(x01) } } } } }
  make_curve(family,"step_gate")        { |x01| gateify(x01)    { |x01| stepify(x01)   { |x01| func.call(x01) } } }
  make_curve(family,"step_m_gate")      { |x01| gateify(x01)    { |x01| hmirorify(x01) { |x01| stepify(x01) { |x01| func.call(x01) } } } }
  
  if ifunc
    make_curve(family,"inverse_step")     { |x01| stepify(x01)    { |x01| ifunc.call(x01) } }
    make_curve(family,"inverse_step_m")   { |x01| hmirorify(x01)  { |x01| stepify(x01)   { |x01| ifunc.call(x01) } } }
    make_curve(family,"inverse_step_rm")  { |x01| stepify(x01)    { |x01| vmirorify(x01) { |x01| hmirorify(x01) { |x01| ifunc.call(x01) } } } }
    make_curve(family,"inverse_step_r")   { |x01| hmirorify(x01)  { |x01| stepify(x01)   { |x01| vmirorify(x01) { |x01| hmirorify(x01) { |x01| ifunc.call(x01) } } } } }  
  end
end
  

def make_xn(family,n)
  make_family(family, Proc.new {|x01| xn(x01,n) }, Proc.new{|x01| ixn(x01,n) })
end

def make_expn(family, n)
  make_family(family, Proc.new {|x01| expd(x01,n)}, Proc.new{|x01| iexpd(x01,n) })
end

def make_circ
  make_family("circ", Proc.new {|x01| circ(x01) })
end

def make_k4
  make_curve("kawaik4","lin_classic")   { |x01| x01 }
  make_curve("kawaik4","exp_classic")   { |x01| expd(x01,1) }
  make_curve("kawaik4","exp2_classic")  { |x01| expd(x01,2) }
  make_curve("kawaik4","lin_clamp_hi")  { |x01|
    if x01 <= 0.75
      x01/0.75
    else
      0
    end
  }
  make_curve("kawaik4","lin_clamp_lo") { |x01|
    if x01 <= 0.75
      0
    else
      x01
    end
  }
end

def make_sstep(order)
  make_curve("sstep", "s#{order}")     { |x01| generalSmoothStep(order,x01) }
  make_curve("sstep", "s#{order}_m")   { |x01| generalSmoothStep(order,1-x01) }
end

def make_sin
  make_family("sin",Proc.new{ |x01| 1 + Math.sin(0.5*Math::PI*(x01-1)) }, Proc.new{ |x01| 1 + (Math.asin(x01 - 1))/(0.5*Math::PI)} )
end

def make_smooth_steps
  (0..14).each{|i| make_sstep(i) }
end

# All these functions were originally meant to be pre-generated and imported.
# But I added parametric sets so they're now covered by the plugin directly.
# make_expn("exp",1)
# make_expn("exp2",2)
# make_expn("exp3",3)
# make_xn("x2",2)
# make_xn("x3",3)
# make_xn("x15",1.5)

make_sin
make_circ
make_k4
make_smooth_steps
