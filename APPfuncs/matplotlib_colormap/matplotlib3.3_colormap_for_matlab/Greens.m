function map = Greens(N)
% MatPlotLib 3.3 配色方案
% 输入:
% N   -  定义colormap长度的整数（N>=0）；若为空，则为当前图窗colormap长度
%
% 输出:
% map -  Nx3的RGB颜色矩阵
%
% Copyright  2020   Akun
% https://zhuanlan.zhihu.com/c_1074615528869531648

if nargin<1 || isempty(N)
	N = size(get(gcf,'colormap'),1);
else
	assert(isscalar(N)&&isreal(N),'First argument must be a real numeric scalar.')
end

C = [0.964705882352941,0.984313725490196,0.956862745098039;0.960784313725490,0.984313725490196,0.952941176470588;0.960784313725490,0.984313725490196,0.952941176470588;0.956862745098039,0.984313725490196,0.949019607843137;0.956862745098039,0.980392156862745,0.945098039215686;0.952941176470588,0.980392156862745,0.945098039215686;0.952941176470588,0.980392156862745,0.941176470588235;0.949019607843137,0.980392156862745,0.937254901960784;0.945098039215686,0.980392156862745,0.937254901960784;0.945098039215686,0.976470588235294,0.933333333333333;0.941176470588235,0.976470588235294,0.929411764705882;0.941176470588235,0.976470588235294,0.929411764705882;0.937254901960784,0.976470588235294,0.925490196078431;0.937254901960784,0.972549019607843,0.921568627450980;0.929411764705882,0.972549019607843,0.917647058823529;0.929411764705882,0.972549019607843,0.917647058823529;0.925490196078431,0.972549019607843,0.913725490196078;0.925490196078431,0.968627450980392,0.909803921568627;0.925490196078431,0.968627450980392,0.909803921568627;0.921568627450980,0.968627450980392,0.905882352941177;0.921568627450980,0.968627450980392,0.905882352941177;0.917647058823529,0.964705882352941,0.898039215686275;0.913725490196078,0.964705882352941,0.898039215686275;0.909803921568627,0.964705882352941,0.894117647058824;0.909803921568627,0.964705882352941,0.890196078431373;0.905882352941177,0.964705882352941,0.890196078431373;0.905882352941177,0.960784313725490,0.886274509803922;0.901960784313726,0.960784313725490,0.882352941176471;0.901960784313726,0.960784313725490,0.882352941176471;0.898039215686275,0.960784313725490,0.878431372549020;0.894117647058824,0.956862745098039,0.874509803921569;0.890196078431373,0.956862745098039,0.870588235294118;0.890196078431373,0.956862745098039,0.866666666666667;0.886274509803922,0.952941176470588,0.862745098039216;0.882352941176471,0.952941176470588,0.858823529411765;0.878431372549020,0.952941176470588,0.854901960784314;0.870588235294118,0.949019607843137,0.847058823529412;0.870588235294118,0.949019607843137,0.847058823529412;0.862745098039216,0.945098039215686,0.839215686274510;0.862745098039216,0.945098039215686,0.839215686274510;0.854901960784314,0.941176470588235,0.831372549019608;0.850980392156863,0.941176470588235,0.827450980392157;0.850980392156863,0.941176470588235,0.827450980392157;0.843137254901961,0.937254901960784,0.819607843137255;0.839215686274510,0.937254901960784,0.815686274509804;0.835294117647059,0.933333333333333,0.811764705882353;0.831372549019608,0.933333333333333,0.807843137254902;0.827450980392157,0.933333333333333,0.803921568627451;0.827450980392157,0.929411764705882,0.800000000000000;0.823529411764706,0.929411764705882,0.796078431372549;0.819607843137255,0.929411764705882,0.792156862745098;0.815686274509804,0.925490196078431,0.788235294117647;0.811764705882353,0.925490196078431,0.784313725490196;0.807843137254902,0.921568627450980,0.780392156862745;0.803921568627451,0.921568627450980,0.776470588235294;0.800000000000000,0.921568627450980,0.772549019607843;0.796078431372549,0.917647058823529,0.768627450980392;0.792156862745098,0.917647058823529,0.764705882352941;0.788235294117647,0.917647058823529,0.760784313725490;0.784313725490196,0.913725490196078,0.756862745098039;0.776470588235294,0.909803921568627,0.749019607843137;0.776470588235294,0.909803921568627,0.749019607843137;0.768627450980392,0.905882352941177,0.741176470588235;0.768627450980392,0.905882352941177,0.741176470588235;0.756862745098039,0.901960784313726,0.733333333333333;0.752941176470588,0.901960784313726,0.725490196078431;0.752941176470588,0.901960784313726,0.725490196078431;0.745098039215686,0.898039215686275,0.717647058823529;0.741176470588235,0.894117647058824,0.713725490196078;0.733333333333333,0.894117647058824,0.709803921568628;0.729411764705882,0.890196078431373,0.705882352941177;0.725490196078431,0.890196078431373,0.698039215686275;0.721568627450980,0.886274509803922,0.694117647058824;0.717647058823529,0.886274509803922,0.690196078431373;0.713725490196078,0.882352941176471,0.686274509803922;0.705882352941177,0.882352941176471,0.682352941176471;0.701960784313725,0.878431372549020,0.678431372549020;0.698039215686275,0.878431372549020,0.670588235294118;0.694117647058824,0.874509803921569,0.666666666666667;0.686274509803922,0.874509803921569,0.662745098039216;0.682352941176471,0.870588235294118,0.658823529411765;0.678431372549020,0.870588235294118,0.654901960784314;0.674509803921569,0.866666666666667,0.650980392156863;0.670588235294118,0.866666666666667,0.647058823529412;0.662745098039216,0.862745098039216,0.635294117647059;0.658823529411765,0.862745098039216,0.635294117647059;0.650980392156863,0.858823529411765,0.627450980392157;0.650980392156863,0.858823529411765,0.627450980392157;0.643137254901961,0.854901960784314,0.619607843137255;0.635294117647059,0.850980392156863,0.611764705882353;0.635294117647059,0.850980392156863,0.611764705882353;0.627450980392157,0.847058823529412,0.603921568627451;0.623529411764706,0.847058823529412,0.600000000000000;0.615686274509804,0.843137254901961,0.596078431372549;0.611764705882353,0.839215686274510,0.592156862745098;0.603921568627451,0.839215686274510,0.584313725490196;0.600000000000000,0.835294117647059,0.580392156862745;0.596078431372549,0.831372549019608,0.576470588235294;0.588235294117647,0.831372549019608,0.572549019607843;0.584313725490196,0.827450980392157,0.568627450980392;0.576470588235294,0.823529411764706,0.564705882352941;0.572549019607843,0.823529411764706,0.556862745098039;0.564705882352941,0.819607843137255,0.552941176470588;0.556862745098039,0.815686274509804,0.545098039215686;0.556862745098039,0.815686274509804,0.545098039215686;0.545098039215686,0.807843137254902,0.537254901960784;0.545098039215686,0.807843137254902,0.537254901960784;0.537254901960784,0.807843137254902,0.529411764705882;0.529411764705882,0.800000000000000,0.521568627450980;0.529411764705882,0.800000000000000,0.521568627450980;0.517647058823530,0.796078431372549,0.513725490196078;0.513725490196078,0.792156862745098,0.509803921568627;0.505882352941176,0.792156862745098,0.505882352941176;0.501960784313726,0.788235294117647,0.498039215686275;0.501960784313726,0.788235294117647,0.498039215686275;0.490196078431373,0.784313725490196,0.490196078431373;0.482352941176471,0.780392156862745,0.486274509803922;0.478431372549020,0.776470588235294,0.482352941176471;0.470588235294118,0.776470588235294,0.478431372549020;0.466666666666667,0.772549019607843,0.470588235294118;0.462745098039216,0.768627450980392,0.466666666666667;0.454901960784314,0.768627450980392,0.462745098039216;0.450980392156863,0.764705882352941,0.458823529411765;0.443137254901961,0.760784313725490,0.454901960784314;0.439215686274510,0.760784313725490,0.454901960784314;0.431372549019608,0.756862745098039,0.450980392156863;0.423529411764706,0.752941176470588,0.447058823529412;0.415686274509804,0.745098039215686,0.439215686274510;0.411764705882353,0.745098039215686,0.439215686274510;0.400000000000000,0.741176470588235,0.435294117647059;0.396078431372549,0.741176470588235,0.435294117647059;0.392156862745098,0.737254901960784,0.431372549019608;0.380392156862745,0.729411764705882,0.423529411764706;0.380392156862745,0.729411764705882,0.423529411764706;0.368627450980392,0.725490196078431,0.419607843137255;0.364705882352941,0.721568627450980,0.415686274509804;0.356862745098039,0.717647058823529,0.411764705882353;0.349019607843137,0.717647058823529,0.411764705882353;0.345098039215686,0.713725490196078,0.407843137254902;0.337254901960784,0.709803921568628,0.403921568627451;0.329411764705882,0.705882352941177,0.400000000000000;0.325490196078431,0.701960784313725,0.396078431372549;0.317647058823529,0.701960784313725,0.396078431372549;0.313725490196078,0.698039215686275,0.392156862745098;0.305882352941177,0.694117647058824,0.388235294117647;0.298039215686275,0.690196078431373,0.384313725490196;0.294117647058824,0.690196078431373,0.380392156862745;0.286274509803922,0.686274509803922,0.380392156862745;0.282352941176471,0.682352941176471,0.376470588235294;0.274509803921569,0.678431372549020,0.372549019607843;0.266666666666667,0.674509803921569,0.368627450980392;0.258823529411765,0.670588235294118,0.364705882352941;0.254901960784314,0.670588235294118,0.364705882352941;0.247058823529412,0.662745098039216,0.356862745098039;0.247058823529412,0.662745098039216,0.356862745098039;0.243137254901961,0.658823529411765,0.356862745098039;0.235294117647059,0.650980392156863,0.349019607843137;0.235294117647059,0.650980392156863,0.349019607843137;0.227450980392157,0.643137254901961,0.345098039215686;0.223529411764706,0.639215686274510,0.341176470588235;0.219607843137255,0.635294117647059,0.337254901960784;0.215686274509804,0.631372549019608,0.333333333333333;0.215686274509804,0.627450980392157,0.333333333333333;0.211764705882353,0.623529411764706,0.329411764705882;0.207843137254902,0.619607843137255,0.325490196078431;0.203921568627451,0.615686274509804,0.321568627450980;0.200000000000000,0.611764705882353,0.317647058823529;0.196078431372549,0.607843137254902,0.317647058823529;0.192156862745098,0.603921568627451,0.313725490196078;0.188235294117647,0.600000000000000,0.309803921568627;0.184313725490196,0.596078431372549,0.305882352941177;0.180392156862745,0.592156862745098,0.305882352941177;0.176470588235294,0.588235294117647,0.301960784313725;0.172549019607843,0.584313725490196,0.298039215686275;0.168627450980392,0.580392156862745,0.294117647058824;0.160784313725490,0.572549019607843,0.290196078431373;0.160784313725490,0.572549019607843,0.290196078431373;0.152941176470588,0.564705882352941,0.282352941176471;0.152941176470588,0.560784313725490,0.282352941176471;0.152941176470588,0.560784313725490,0.282352941176471;0.145098039215686,0.552941176470588,0.274509803921569;0.145098039215686,0.552941176470588,0.274509803921569;0.137254901960784,0.545098039215686,0.270588235294118;0.133333333333333,0.541176470588235,0.266666666666667;0.129411764705882,0.537254901960784,0.262745098039216;0.121568627450980,0.533333333333333,0.258823529411765;0.117647058823529,0.529411764705882,0.258823529411765;0.113725490196078,0.525490196078431,0.254901960784314;0.109803921568627,0.521568627450980,0.250980392156863;0.105882352941176,0.517647058823530,0.247058823529412;0.101960784313725,0.513725490196078,0.243137254901961;0.0980392156862745,0.509803921568627,0.243137254901961;0.0941176470588235,0.505882352941176,0.239215686274510;0.0901960784313726,0.501960784313726,0.235294117647059;0.0823529411764706,0.494117647058824,0.227450980392157;0.0823529411764706,0.494117647058824,0.227450980392157;0.0745098039215686,0.494117647058824,0.227450980392157;0.0705882352941177,0.490196078431373,0.223529411764706;0.0666666666666667,0.486274509803922,0.219607843137255;0.0588235294117647,0.478431372549020,0.215686274509804;0.0588235294117647,0.478431372549020,0.215686274509804;0.0509803921568627,0.470588235294118,0.207843137254902;0.0470588235294118,0.466666666666667,0.203921568627451;0.0470588235294118,0.466666666666667,0.203921568627451;0.0392156862745098,0.458823529411765,0.200000000000000;0.0352941176470588,0.458823529411765,0.200000000000000;0.0274509803921569,0.450980392156863,0.192156862745098;0.0235294117647059,0.447058823529412,0.188235294117647;0.0196078431372549,0.443137254901961,0.188235294117647;0.0156862745098039,0.439215686274510,0.184313725490196;0.0117647058823529,0.435294117647059,0.180392156862745;0.00784313725490196,0.435294117647059,0.176470588235294;0.00392156862745098,0.431372549019608,0.172549019607843;0,0.427450980392157,0.172549019607843;0,0.419607843137255,0.168627450980392;0,0.415686274509804,0.168627450980392;0,0.411764705882353,0.164705882352941;0,0.407843137254902,0.160784313725490;0,0.396078431372549,0.156862745098039;0,0.396078431372549,0.156862745098039;0,0.392156862745098,0.156862745098039;0,0.384313725490196,0.152941176470588;0,0.380392156862745,0.152941176470588;0,0.372549019607843,0.149019607843137;0,0.372549019607843,0.149019607843137;0,0.360784313725490,0.145098039215686;0,0.356862745098039,0.141176470588235;0,0.356862745098039,0.141176470588235;0,0.345098039215686,0.137254901960784;0,0.345098039215686,0.137254901960784;0,0.337254901960784,0.133333333333333;0,0.329411764705882,0.129411764705882;0,0.325490196078431,0.129411764705882;0,0.321568627450980,0.125490196078431;0,0.313725490196078,0.125490196078431;0,0.309803921568627,0.121568627450980;0,0.305882352941177,0.121568627450980;0,0.301960784313725,0.117647058823529;0,0.294117647058824,0.117647058823529;0,0.290196078431373,0.113725490196078;0,0.286274509803922,0.113725490196078;0,0.278431372549020,0.109803921568627;0,0.270588235294118,0.105882352941176;0,0.270588235294118,0.105882352941176;0,0.270588235294118,0.105882352941176];

num = size(C,1);
vec = linspace(0,num+1,N+2);
map = interp1(1:num,C,vec(2:end-1),'linear','extrap'); %...插值
map = max(0,min(1,map));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
% 制作：阿昆            %%%
% 公众号：阿昆的科研日常 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%